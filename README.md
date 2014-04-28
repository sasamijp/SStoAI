# SStoAI

ショートストーリーを人工無能に変換します

## Installation

`git clone git://github.com/sasamijp/SStoAI.git SStoAI`

`cd SStoAI`

`bundle install`


## Usage

###作成

./以下にディレクトリを作成し、SSを自動収集して学習データを作る:  

`bundle exec bin/SStoAI new tarou 太郎`


###話しかける

話しかける:

`bundle exec bin/SStoAI talk tarou 元気ですか`

###botとして動かす

./tarou/key.rbにbotとして動かしたいアカウントのCK/CSその他もろもろを入れておく  
なんかbundlerでやったらうまくいかんかったもうやだ  
`gem install twitter`  
`gem install tweetstream`

起動:  

`bundle exec bin/SStoAI twitterbot tarou`


###何かあれば@sasamijpまで
