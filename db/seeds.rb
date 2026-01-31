# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding HitGuessr database..."

# Create users
users = [
  { email: "jean@example.com", name: "Jean Dupont", password: "password123" },
  { email: "marie@example.com", name: "Marie Martin", password: "password123" },
  { email: "pierre@example.com", name: "Pierre Bernard", password: "password123" },
  { email: "sophie@example.com", name: "Sophie Petit", password: "password123" },
  { email: "lucas@example.com", name: "Lucas Moreau", password: "password123" }
]

created_users = users.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = attrs[:password]
  end
end

puts "✅ #{created_users.count} utilisateurs créés"

# Create a team
organizer = created_users.first
team = Team.find_or_create_by!(name: "Les Mélomanes") do |t|
  t.organizer = organizer
end

puts "✅ Équipe '#{team.name}' créée (organisateur: #{organizer.name})"

# Add members to team (organizer is already added via callback)
created_users[1..].each do |user|
  unless team.members.include?(user)
    team.memberships.create!(user: user)
    puts "   ↳ Membre ajouté: #{user.name}"
  end
end

puts "✅ #{team.members.count} membres dans l'équipe"

# Create a finished game for demonstration
game = team.games.create!(status: :collecting)
puts "✅ Partie ##{game.id} créée"

# Create proposals for each member
proposals_urls = [
  "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "https://www.youtube.com/watch?v=9bZkp7q19f0",
  "https://www.youtube.com/watch?v=kJQP7kiw5Fk",
  "https://www.youtube.com/watch?v=JGwWNGJdvx8",
  "https://www.youtube.com/watch?v=fJ9rUzIMcZQ"
]

team.members.each_with_index do |member, i|
  unless game.proposals.exists?(player: member)
    game.proposals.create!(player: member, url: proposals_urls[i])
    puts "   ↳ Proposition soumise par #{member.name}"
  end
end

# Transition to guessing phase
if game.collecting?
  game.start_guessing!
  puts "✅ Partie passée en phase de devinettes"
end

# Create guesses for each player
game.proposals.includes(:player).each do |proposal|
  game.proposals.where.not(player: proposal.player).each do |other_proposal|
    guessing_player = other_proposal.player

    unless Guess.exists?(player: guessing_player, proposal: proposal)
      # Randomly guess (sometimes correct, sometimes not)
      possible_authors = game.proposals.pluck(:player_id)
      guessed_author_id = [ proposal.player_id, possible_authors.sample ].sample

      Guess.create!(
        player: guessing_player,
        proposal: proposal,
        guessed_author_id: guessed_author_id
      )
    end
  end
end

puts "✅ Devinettes soumises"

# Finish the game
if game.guessing?
  game.finish!
  puts "✅ Partie terminée"
end

# Display final ranking
puts "\n🏆 Classement final:"
game.ranking.each do |entry|
  puts "   #{entry[:rank]}. #{entry[:player].name} - #{entry[:score]} pts"
end

puts "\n🎉 Seeding terminé ! Connectez-vous avec:"
puts "   Email: jean@example.com"
puts "   Mot de passe: password123"
