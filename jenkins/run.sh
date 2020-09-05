#!/bin/bash

echo "开始打包了"

# # 记录一下开始时间
echo `date` 

branch=$1
echo "当前分支：${branch}"

path=$2
echo "当前路径：${path}"

project=$3
echo "当前项目：${project}"

env=""
if [[ $branch == *"develop"* ]]
then
     echo "当前分支为测试环境"
     env="测试环境"
fi

if [[ $branch == *"pre_production"* ]]
then
     echo "当前分支为预生产环境"
     env="预生产环境"
fi

if [[ $branch == "refs/heads/production" ]]
then
     echo "当前分支为生产环境"
     env="生产环境"
fi

#发送钉钉通知
curl https://oapi.dingtalk.com/robot/send?access_token=78ac29c224e94ae199fb918e37d0db8af90280523bf6e6ae176e883cd1cc2a9b\
    -H 'Content-Type: application/json' \
    -d '{"msgtype": "text", 
         "text": {
              "content": "iOS'${project}' '${env}'内测版有更新，预计构建时间10分钟，请稍后..."
         }
       }'



cd ${path}

echo `pwd`

export LC_ALL=en_US.UTF-8;
export LANG=en_US.UTF-8;

#bundle install —- path vendor/bundler
bundle exec fastlane add_plugin versioning
bundle exec fastlane add_plugin fir_cli
fastlane customer_development branch:${branch} path:${path}
echo '打包客户端完毕'

# 保存打包时间到日志
echo `date '+%Y-%m-%d %H:%M:%S'`  > "${path}/lastArchiveDate.log"

echo 'finish'

# 发送 @ 消息到具体某人
curl https://oapi.dingtalk.com/robot/send?access_token=78ac29c224e94ae199fb918e37d0db8af90280523bf6e6ae176e883cd1cc2a9b\
    -H 'Content-Type: application/json' \
    -d '{"msgtype": "text", 
         "text": {
              "content": "iOS '${project}' '${env}'安装包已经更新完成，请知悉..."
         },
         "at": {
        	"atMobiles": [
            
        	], 
        	"isAtAll": true
    	}
       }'

