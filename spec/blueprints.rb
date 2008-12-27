require 'faker'

Sham.title { Faker::Lorem.sentence }
Sham.host  { Faker::Internet.domain_name }
Sham.name  { Faker::Name.name }
Sham.login { Faker::Internet.user_name }
Sham.email { Faker::Internet.email }
Sham.url   { "http://#{Faker::Internet.domain_name}/" }
Sham.body  { Faker::Lorem.paragraphs }
Sham.tag   { Faker::Lorem.words(1) }

Site.blueprint do
  title              { Sham.title }
  host               { Sham.host }
  approve_comments   { true }
  comment_age        { 30 }
  timezone           { TZInfo::Timezone.new("America/New_York") }
  articles_per_page  { 15 }
  permalink_style    { ":year/:month/:day/:permalink" }
  tag_path           { 'tags' }
  search_path        { 'search' }
  current_theme_path { 'current' }
end

User.blueprint do
  login            { Sham.login }
  email            { Sham.email }
  token            { 'quentintoken' }
  admin            { false }
  password         { 'password' }
  password_confirmation { 'password' }
end

Membership.blueprint do
  site
  user
  admin { false }
end

Article.blueprint do
  site
  user
  title        { Sham.title }
  body         { Sham.body }
  filter       { "textile_filter" }
  created_at   { Time.now - 3.days }
  published_at { Time.now - 2.days }
  comment_age  { 0 }
end

Comment.blueprint do
  article
  author       { Sham.name }
  author_email { Sham.email }
  author_url   { Sham.url }
  author_ip    { "127.0.0.1" }
  body         { Sham.body }
end

Tag.blueprint do
  name         { Sham.tag }
end

Event.class_eval do
  blueprint do
    site
    mode       { 'publish' } # or 'edit', 'comment'
    title      { Sham.title }
    body       { Sham.body }
    created_at { Time.now - 3.days }
    # These can be nil, depending on the type of comment
    # author
    # comment
    # user 
  end

  def self.make_from(record)
    options = {:title => record.title, :body => record.body, :site => record.site, :mode => Event.mode_from(record)}
    if record.is_a?(Comment)
      options.update :article => record.article, :comment => record, :author => record.author
    else
      options.update :article => record, :user => record.updater || record.user
    end
    Event.make(options)
  end
end
