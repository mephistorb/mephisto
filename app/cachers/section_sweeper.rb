class SectionSweeper < ArticleSweeper
  observe Section
  undef :after_create
  undef :before_save
end