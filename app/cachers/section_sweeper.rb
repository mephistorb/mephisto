class CategorySweeper < ArticleSweeper
  observe Category
  undef :after_create
end