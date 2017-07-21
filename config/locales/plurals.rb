# See https://github.com/svenfuchs/i18n/blob/master/test/test_data/locales/plurals.rb
{
  :en => { :i18n => { :plural => { :keys => [:one, :other], :rule => lambda { |n| n == 1 ? :one : :other } } } },
  :fr => { :i18n => { :plural => { :keys => [:one, :other], :rule => lambda { |n| n.between?(0, 2) && n != 2 ? :one : :other } } } },
  :pl => { :i18n => { 
    :plural => { 
      :keys => [:one, :few, :many, :other], 
      :rule => lambda { 
        |n| n == 1 ? :one : 
        [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100) ? :few : (n != 1 && [0, 1].include?(n % 10)) || [5, 6, 7, 8, 9].include?(n % 10) || [12, 13, 14].include?(n % 100) ? :many : :other 
        } 
      } 
    } 
  }
}
#
# 0 elements” is “0 elementów”, 
# one “1 element” is “1 element”, 
# few “2 elements” is “2 elementy”, but it gets tricky. With 5 it’s 
# many “5 elementów” again until 21 and it changes when the number reaches 22 – it’s 
# other “22 elementy” again. And so on
#
#
