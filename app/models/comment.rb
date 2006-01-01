class Comment < Article
  belongs_to :article

  def to_liquid
    attributes
  end

  protected
  validates_presence_of :description, :author, :author_ip
end
