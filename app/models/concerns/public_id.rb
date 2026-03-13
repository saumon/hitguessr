# frozen_string_literal: true

module PublicId
  extend ActiveSupport::Concern

  SEGMENT_LENGTH = 8
  SEGMENT_CHARSET = [ *"A".."Z", *"a".."z", *"0".."9" ].freeze
  MAX_RETRIES = 5

  included do
    before_create :generate_public_id

    validates :public_id, presence: true, on: :update
    validates :public_id, uniqueness: true, allow_nil: true
    validates :public_id, format: {
      with: ->(record) { /\A#{record.class.public_id_prefix}_[A-Za-z0-9]{#{SEGMENT_LENGTH}}\z/ },
      message: "format invalide"
    }, allow_nil: true
  end

  class_methods do
    def public_id_prefix
      raise NotImplementedError, "#{name} must define .public_id_prefix"
    end
  end

  def to_param
    public_id
  end

  private

  def generate_public_id
    return if public_id.present?

    prefix = self.class.public_id_prefix
    MAX_RETRIES.times do
      segment = Array.new(SEGMENT_LENGTH) { SEGMENT_CHARSET.sample }.join
      candidate = "#{prefix}_#{segment}"

      unless self.class.exists?(public_id: candidate) ||
             cross_model_collision?(segment)
        self.public_id = candidate
        return
      end
    end

    Rails.logger.error("[PublicId] Retry exhaustion for #{self.class.name}: failed to generate unique public_id after #{MAX_RETRIES} attempts")
    raise "Could not generate unique public_id after #{MAX_RETRIES} attempts"
  end

  def cross_model_collision?(segment)
    other_models = [ Game, Team ] - [ self.class ]
    other_models.any? { |model| model.where("public_id LIKE ?", "%_#{segment}").exists? }
  end
end
