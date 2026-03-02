require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  def setup
    suffix = SecureRandom.hex(6)

    @organizer = User.create!(
      email: "organizer-#{suffix}@example.com",
      name: "Organisateur",
      password: "password123"
    )
    @member = User.create!(
      email: "member-#{suffix}@example.com",
      name: "Membre",
      password: "password123"
    )
    @member_two = User.create!(
      email: "member-two-#{suffix}@example.com",
      name: "Membre Deux",
      password: "password123"
    )
  end

  test "user can create a team" do
    sign_in_as @organizer

    visit teams_path
    click_link "+ Créer une équipe"

    fill_in "Nom de l'équipe", with: "Les Mélomanes"
    click_button "Créer l'équipe"

    assert_text "Équipe créée avec succès"
    assert_text "Les Mélomanes"
    assert_text "Organisateur: #{@organizer.name}"
  end

  test "organizer can add members to team" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)

    visit team_path(team)
    find("details.members-details summary").click

    fill_in "Email du membre à ajouter", with: @member.email
    click_button "+ Ajouter"

    assert_text "#{@member.name} a été ajouté"
    assert_text @member.name
  end

  test "organizer can remove members from team" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    team.memberships.create!(user: @member)

    visit team_path(team)
    find("details.members-details summary").click

    accept_confirm do
      click_button "Retirer"
    end

    assert_text "#{@member.name} a été retiré"
  end

  test "organizer can launch a game" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)

    visit team_path(team)
    click_link "🎧 Lancer une partie"

    click_button "Lancer la partie"

    assert_text "Partie lancée"
    assert_text "PHASE: Collecte des propositions"
  end

  test "organizer sees launch disabled for team with fewer than three members" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Duo", organizer: @organizer)
    team.memberships.create!(user: @member)

    visit team_path(team)

    assert_no_link "🎧 Lancer une partie"
    assert_selector "span", text: "Au moins 3 membres requis", visible: false
  end

  test "new game page shows explicit refusal message for ineligible team" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Solo", organizer: @organizer)

    visit new_team_game_path(team)

    assert_text "Au moins 3 membres sont requis pour lancer une partie."
    assert_button "Lancer la partie", disabled: true
  end

  test "user sees their teams on index page" do
    Team.create!(name: "Les Mélomanes", organizer: @organizer)
    team2 = Team.create!(name: "Rock Fans", organizer: @member)
    team2.memberships.create!(user: @organizer)

    sign_in_as @organizer

    visit teams_path

    assert_text "Les Mélomanes"
    assert_text "Rock Fans"
  end

  test "organizer can edit team name" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)

    visit team_path(team)
    click_link "Éditer"

    fill_in "Nom de l'équipe", with: "Les Super Mélomanes"
    click_button "Mettre à jour"

    assert_text "Équipe mise à jour"
    assert_text "Les Super Mélomanes"
  end

  test "organizer can delete team" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)

    visit team_path(team)

    accept_confirm do
      click_button "Supprimer"
    end

    assert_text "Équipe supprimée"
    assert_no_text "Les Mélomanes"
  end

  # ==============================================
  # Feature 012 – US1: Membre peut progresser la partie
  # ==============================================

  test "team member (non-organizer) sees the launch button and can create a game" do
    team = Team.create!(name: "Les Testeurs", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)

    sign_in_as @member

    visit team_path(team)

    assert_link "🎧 Lancer une partie"
    click_link "🎧 Lancer une partie"
    click_button "Lancer la partie"

    assert_text I18n.t("games.create.success")
    assert_text "PHASE: Collecte des propositions"
  end

  test "team member (non-organizer) can trigger start_guessing" do
    team = Team.create!(name: "Les Devineurs", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :collecting)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")
    game.proposals.create!(player: @member,    url: "https://youtube.com/2")

    sign_in_as @member

    visit game_path(game)

    assert_button "⚠️ Passer aux devinettes"

    accept_confirm do
      click_button "⚠️ Passer aux devinettes"
    end

    assert_text I18n.t("games.start_guessing.success")
    assert game.reload.guessing?
  end

  test "team member (non-organizer) can trigger finish" do
    team = Team.create!(name: "Les Finisseurs", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :guessing, started_at: Time.current)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")
    game.proposals.create!(player: @member,    url: "https://youtube.com/2")

    sign_in_as @member

    visit game_path(game)

    assert_button "⚠️ Terminer la partie"

    accept_confirm do
      click_button "⚠️ Terminer la partie"
    end

    assert_text I18n.t("games.finish.success")
    assert game.reload.finished?
  end

  # ==============================================
  # Feature 012 – US2: Actions organisateur-only restent protégées
  # ==============================================

  test "team member (non-organizer) does not see cancel game button" do
    team = Team.create!(name: "Les Protégés", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :collecting)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")

    sign_in_as @member

    visit game_path(game)

    assert_no_button "🗑️ Annuler la partie"
  end

  test "organizer sees cancel game button in collecting phase" do
    team = Team.create!(name: "Les Organisateurs", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :collecting)

    sign_in_as @organizer

    visit game_path(game)

    assert_button "🗑️ Annuler la partie"
  end

  test "team member does not see add/remove member controls" do
    team = Team.create!(name: "Les Gouvernés", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)

    sign_in_as @member

    visit team_path(team)
    find("details.members-details summary").click

    assert_no_field "Email du membre à ajouter"
    assert_no_button "Retirer"
  end

  test "organizer sees add member form and remove buttons" do
    team = Team.create!(name: "Les Maîtres", organizer: @organizer)
    team.memberships.create!(user: @member)

    sign_in_as @organizer

    visit team_path(team)
    find("details.members-details summary").click

    assert_field "Email du membre à ajouter"
    assert_button "Retirer"
  end

  # ==============================================
  # Feature 012 – US3: Visibilité des permissions
  # ==============================================

  test "non-organizer member sees start_guessing button but not cancel" do
    team = Team.create!(name: "Clarté Rôles", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :collecting)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")
    game.proposals.create!(player: @member,    url: "https://youtube.com/2")

    sign_in_as @member

    visit game_path(game)

    assert_button "⚠️ Passer aux devinettes"
    assert_no_button "🗑️ Annuler la partie"
  end

  test "organizer sees both start_guessing and cancel buttons" do
    team = Team.create!(name: "Clarté Organisateur", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :collecting)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")
    game.proposals.create!(player: @member,    url: "https://youtube.com/2")

    sign_in_as @organizer

    visit game_path(game)

    assert_button "⚠️ Passer aux devinettes"
    assert_button "🗑️ Annuler la partie"
  end

  test "non-organizer member sees finish button but not cancel in guessing phase" do
    team = Team.create!(name: "Clarté Fin", organizer: @organizer)
    team.memberships.create!(user: @member)
    team.memberships.create!(user: @member_two)
    game = team.games.create!(status: :guessing, started_at: Time.current)
    game.proposals.create!(player: @organizer, url: "https://youtube.com/1")
    game.proposals.create!(player: @member,    url: "https://youtube.com/2")

    sign_in_as @member

    visit game_path(game)

    assert_button "⚠️ Terminer la partie"
    assert_no_button "🗑️ Annuler la partie"
  end
end
