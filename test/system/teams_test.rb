require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  def setup
    @organizer = User.create!(
      email: "organizer@example.com",
      name: "Organisateur",
      password: "password123"
    )
    @member = User.create!(
      email: "member@example.com",
      name: "Membre",
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

    # Find the remove button for the member (not the organizer)
    within(:xpath, "//div[contains(text(), '#{@member.name}')]/..") do
      accept_confirm do
        click_button "Retirer"
      end
    end

    assert_text "#{@member.name} a été retiré"
  end

  test "organizer can launch a game" do
    sign_in_as @organizer
    team = Team.create!(name: "Les Mélomanes", organizer: @organizer)
    team.memberships.create!(user: @member)

    visit team_path(team)
    click_link "🎮 Lancer une partie"

    click_button "Lancer la partie"

    assert_text "Partie lancée"
    assert_text "PHASE: Collecte des propositions"
  end

  test "user sees their teams on index page" do
    team1 = Team.create!(name: "Les Mélomanes", organizer: @organizer)
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
end
