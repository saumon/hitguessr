module TeamsHelper
  def leave_team_action_label
    t("teams.leave_action.label", default: "Quitter l'équipe")
  end

  def leave_team_confirmation_text
    t("teams.leave_action.confirmation", default: "Êtes-vous sûr de vouloir quitter cette équipe ?")
  end

  def show_leave_team_action_for?(team:, member:, current_user:)
    member == current_user && member != team.organizer
  end

  def leave_team_button_for(team)
    button_to leave_team_action_label,
              team_leave_path(team),
              method: :delete,
              data: { turbo_confirm: leave_team_confirmation_text },
              class: "neon-text-pink hover:opacity-80 text-sm transition-all duration-300 cursor-pointer",
              form: { class: "w-full sm:w-auto" }
  end
end
