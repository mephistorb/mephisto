# The base model for all assets.  It acts slightly different depending on what it is attached to.
# If it's a Site Asset, it is used for adding images to articles.
# If it's a User Asset, it's a profile image.
# Template and Resource inherit from Asset but serve different purposes.
class Asset < Attachment
  validates_presence_of :attachable_id, :attachable_type
  belongs_to :attachable, :polymorphic => true
end
