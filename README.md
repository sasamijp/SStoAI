# SStoAI

ショートストーリーを人工無能に変換します

## Installation

`git clone git://github.com/sasamijp/SStoAI.git SStoAI`

`cd SStoAI`

`bundle install`


## Usage

###作成

home以下にディレクトリを作成し、SSを自動収集して学習データを作る:  

`bundle exec bin/SStoAI new harukabot 春香`


###話しかける

ホームに移動:

`cd ~`

作られたフォルダに移動:  

`cd harukabot`

gemいれる:

`bundle install`

話しかける:

`ruby cli.rb talk 元気ですか`

###botとして動かす

./libs/key.rbにbotとして動かしたいアカウントのCK/CSその他もろもろを入れておく  

起動:  

`ruby cli.rb twitterbot`


###何かあれば@sasamijpまで
