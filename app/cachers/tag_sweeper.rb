class TagSweeper < ArticleSweeper
  observe Tag
  undef :after_create
end