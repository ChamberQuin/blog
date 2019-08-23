# UML的正确姿势

视频上传服务于2013年上线，曾在2个部门间流转，被鬼畜的需求蹂躏，代码质量随着业务的蓬勃发展而一落千丈，高耦合低内聚，在2019年初落到我手上。

送上一张循环依赖图

为了更好地了解并重构代码，选择通过UML从不同方面切入。

# 时序图

# 组件图

# 包图

# 类图

# 部署图


[Valar Morghulis][Sve][bx] sve接口探测异常!
2019-08-18 13:45:20

sve 接口超时!
uri:https://47.95.48.27/2/multimedia/upload/gop/upload.json?upload_id=440663496725563200&index=1&type=video&start_time=0.0&end_time=3.0&md5=745a90065145735cda021ebc5e782512&source=209678993&access_token=2.00yGvVQEwu8srD7ba814f9dbHmOyJB&app_token=OXPNWTUVWWQXOUPYOT%3DONYUQYORXOSTTPTTNOOXXf6q81Eb4g%24&detectid=c5a8794d-5140-40bd-83c4-da1ffffa2d93&request_id=detect-f199e9fb-b5a0-47f1-af64-16e04109f4a5
耗时:[dns:0, connect:19, connect_timeout_setting:5000, read_timeout_setting:10000]
dns结果:/47.95.48.27
总超时设置:10000
执行栈:java.net.SocketOutputStream.socketWrite0(Native Method)
java.net.SocketOutputStream.socketWrite(SocketOutputStream.java:111)
java.net.SocketOutputStream.write(SocketOutputStream.java:155)
sun.security.ssl.OutputRecord.writeBuffer(OutputRecord.java:431)
sun.security.ssl.OutputRecord.write(OutputRecord.java:417)

evaUrl: Eva报告: http://eva.intra.weibo.com/report/detect?traceId=3c3c44c64a6e124d
监控机 : [172.16.105.91, 123.125.105.91]
停报警 : echo "off resource SveScheduledTask.sveOuterCheck" | nc "172.16.105.91" "880"

[INFO] 20190818 13:45:10.550 [catalina-exec-126] GopUploadServiceImpl - uploadGop upload_id->media_id found  mediaId:4406634965862229, uploadParam:UploadParam{authUser=AuthUser  [uid=3908560412, appid=897, appkey=3544521334, ip= 123.125.105.91], clientInfo=ClientInfo{client=other, userAgent='Java/1.8.0_141', network='null', from='null', subFrom='null', lang='null'}, uploadId='440663496725563200', mediaId='null', uploadProtocol=sve, bizType='video', chunkCheck='745a90065145735cda021ebc5e782512', chunkIndex=1, totalCount=null, totalSize=null, totalCheck='null', chunkStartTime=0.0, chunkEndTime=3.0, chunkSize=null, chunkStartLoc=null, trans=false, dynamic=false, paramMap=null, headerMap=null} req_4d126e4ac6443c3c
[INFO] 20190818 13:45:48.369 [catalina-exec-126] TemporaryStorageOSSClient - oss save succ, fileKey:gop/440663496725563200.1.input, result: etag:745A90065145735CDA021EBC5E782512, requestId:5D58E5E61C2D35F9CBF69812, cost:37819 req_4d126e4ac6443c3c



