require "application_system_test_case"

# Test système pour la feature 013: Alerte de doublon de proposition
# Couvre US1 (indicateurs temps réel), US2 (modal bloquante), US3 (confirmation)
class GuessesDuplicateWarningTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(email: "organizer@example.com", name: "Organisateur", password: "password123")
    @player1   = User.create!(email: "player1@example.com",   name: "Joueur 1",     password: "password123")
    @player2   = User.create!(email: "player2@example.com",   name: "Joueur 2",     password: "password123")
    @player3   = User.create!(email: "player3@example.com",   name: "Joueur 3",     password: "password123")

    @team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    @team.memberships.create!(user: @player1)
    @team.memberships.create!(user: @player2)
    @team.memberships.create!(user: @player3)

    @game = @team.games.create!

    # Désactiver le callback d'auto-progression pour éviter que la création du
    # 4e proposal (quorum atteint) ne déclenche start_guessing! automatiquement,
    # ce qui rendrait le start_guessing! explicite ci-dessous invalide.
    Proposal.skip_callback(:commit, :after, :try_auto_progress_game)
    @game.proposals.create!(player: @organizer, url: "https://youtube.com/org")
    @game.proposals.create!(player: @player1,   url: "https://youtube.com/p1")
    @game.proposals.create!(player: @player2,   url: "https://youtube.com/p2")
    @game.proposals.create!(player: @player3,   url: "https://youtube.com/p3")
    Proposal.set_callback(:commit, :after, :try_auto_progress_game)

    @game.reload
    @game.start_guessing!
    # @player1 verra 3 propositions (org, p2, p3) et aura 3 options (Organisateur, Joueur 2, Joueur 3)
  end

  # Attendre que le contrôleur Stimulus guess-duplicates soit connecté
  def wait_for_stimulus
    assert_selector "[data-controller-ready='true']", wait: 5
  end

  # Cocher un radio par index de row et label de joueur via JS
  # Évite les problèmes de stale node references avec within() / choose / Capybara nodes
  # Déclenche aussi les événements change et input pour que Stimulus handleChange s'exécute
  def choose_player_in_row(row_idx, player_name)
    result = execute_script(<<~JS, row_idx, player_name)
      const rows = document.querySelectorAll("[data-guess-duplicates-target='row']");
      const row = rows[arguments[0]];
      if (!row) return { error: 'row not found: ' + arguments[0] };
      const labels = row.querySelectorAll("label");
      for (const label of labels) {
        if (label.textContent.trim().includes(arguments[1])) {
          const radio = label.querySelector("input[type='radio']");
          if (radio) {
            radio.checked = true;
            radio.dispatchEvent(new Event('change', { bubbles: true }));
            radio.dispatchEvent(new Event('input', { bubbles: true }));
            return { ok: true, value: radio.value };
          }
        }
      }
      return { error: 'player not found: ' + arguments[1] };
    JS
    raise "choose_player_in_row(#{row_idx}, \"#{player_name}\") failed: #{result}" if result.is_a?(Hash) && result["error"]
  end

  # Déclencher interceptSubmit directement via l'API Stimulus (window.Stimulus)
  # execute_script("...click()") ne déclenche pas les data-action listeners Stimulus
  def js_stimulus_intercept
    result = execute_script(<<~JS)
      const form = document.querySelector('[data-controller="guess-duplicates"]');
      if (!form) return { error: 'no form' };
      if (!window.Stimulus) return { error: 'no window.Stimulus' };
      const ctrl = window.Stimulus.getControllerForElementAndIdentifier(form, 'guess-duplicates');
      if (!ctrl) return { error: 'no controller found' };
      const evt = new MouseEvent('click', { bubbles: true, cancelable: true });
      ctrl.interceptSubmit(evt);
      return { ok: true };
    JS
    raise "js_stimulus_intercept failed: #{result}" if result.is_a?(Hash) && result["error"]
  end

  # =============================
  # US1 — Indicateurs temps réel
  # =============================

  test "doublon sur deux propositions affiche deux indicateurs" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    # Initialement aucun indicateur visible
    assert_no_selector "[data-testid^='duplicate-indicator']", wait: 2

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")

    # Les deux propositions concernées affichent un indicateur
    assert_selector "[data-testid^='duplicate-indicator']", count: 2, wait: 2
  end

  test "résolution d'un doublon retire les indicateurs concernés" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")

    assert_selector "[data-testid^='duplicate-indicator']", count: 2, wait: 2

    # Résoudre: changer la 2e sélection
    choose_player_in_row(1, "Joueur 3")

    # Plus aucun indicateur
    assert_no_selector "[data-testid^='duplicate-indicator']", wait: 2
  end

  # ======================================
  # US2 — Modal bloquante à la soumission
  # ======================================

  test "soumission avec doublons ouvre la modal de confirmation" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")
    choose_player_in_row(2, "Joueur 3")

    js_stimulus_intercept

    assert_selector "[data-testid='duplicate-modal']", visible: true, wait: 3
  end

  test "soumission sans doublon bypass la modal" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 3")
    choose_player_in_row(2, "Organisateur")

    js_stimulus_intercept

    assert_no_selector "[data-testid='duplicate-modal']", visible: true
    assert_text "Devinettes soumises avec succès", wait: 5
  end

  test "la modal liste le nom et les numéros de propositions concernés" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")
    choose_player_in_row(2, "Joueur 3")

    js_stimulus_intercept

    assert_selector "[data-testid='duplicate-modal']", visible: true, wait: 2
    within("[data-testid='duplicate-modal-list']") do
      assert_text "Joueur 2"
      assert_text "#1"
      assert_text "#2"
    end
  end

  # ===================================
  # US3 — Autoriser les doublons intentionnels
  # ===================================

  test "Annuler ferme la modal sans soumettre" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")
    choose_player_in_row(2, "Joueur 3")

    js_stimulus_intercept
    assert_selector "[data-testid='duplicate-modal']", visible: true, wait: 3

    # Utiliser JS pour les boutons d'une modal fixed-position (contournement coordonnées Selenium)
    execute_script("document.querySelector('[data-testid=\"duplicate-modal-cancel\"]').click()")

    assert_no_selector "[data-testid='duplicate-modal']", visible: true, wait: 2
    assert_current_path new_game_guess_path(@game)
  end

  test "Confirmer soumet les devinettes malgré les doublons" do
    sign_in_as @player1
    visit new_game_guess_path(@game)
    wait_for_stimulus

    choose_player_in_row(0, "Joueur 2")
    choose_player_in_row(1, "Joueur 2")
    choose_player_in_row(2, "Joueur 3")

    js_stimulus_intercept
    assert_selector "[data-testid='duplicate-modal']", visible: true, wait: 3

    # Utiliser JS pour les boutons d'une modal fixed-position (contournement coordonnées Selenium)
    execute_script("document.querySelector('[data-testid=\"duplicate-modal-confirm\"]').click()")

    assert_text "Devinettes soumises avec succès", wait: 5
  end
end
