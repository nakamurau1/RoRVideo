# http://d.hatena.ne.jp/Kazzz/20090325/p1
# ↑　このページを参考に、以下のコードをenvironment.rbから移行

# WillpaginateのPreviout_label,Next_labelをカスタマイズ
# WillPaginate::ViewHelpers.pagination_options[:previous_label] = '&lt Previous'
# WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next &gt'
# → 上記２行があると、HerokuSchedulerが実行されないのでコメントアウト
# → HerokuSchedulerでエラーを起こさずにNextLabel, PreviousLabelを設定する方法がないか探す。