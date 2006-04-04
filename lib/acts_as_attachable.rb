module ActsAsAttachable
  def self.included(base)
    base.validates_presence_of :attachable_id, :attachable_type
    base.belongs_to :attachable, :polymorphic => true
  end
end