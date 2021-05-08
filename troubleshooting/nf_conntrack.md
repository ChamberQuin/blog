# nf_conntrack丢包

1. 现象

	A调用B偶发`java.net.UnknownHostException`，整体报错量较往日高。

2. 分析

	DNS解析失败与应用层无关，确认界限，重点排查系统及网络。

	1. 网络
		
		机器上简单`dig`几次正常，加ping监控并抓包以进一步分析。
		
	2. 系统
		
		Linux协议栈主要有3层
		
		* socket
		* intermediate protocol, eg: tcp, ip, udp
		* MAC, eg: 网卡
		
		DNS解析通常走UDP发包，某些情况也走TCP发包，怀疑协议栈后两层有问题导致偶发收发包失败。
		
		
		
	```
	[root@93-44-159-aliyun-core logs]# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0      1500 35359155659      0      0 0      32354726867      0      0      0 BMRU
lo       65536 88266356      0      0 0      88266356      0      0      0 LRU
	
	[root@93-44-159-aliyun-core logs]# netstat -s
Ip:
    34522229676 total packets received
    0 forwarded
    0 incoming packets discarded
    34519702014 incoming packets delivered
    32440795053 requests sent out
    37875 outgoing packets dropped
    1 dropped because of missing route
    2119931 fragments received ok
    4239862 fragments created
Icmp:
    2660922 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 187293
        timeout in transit: 6
        echo requests: 584468
        echo replies: 1889155
    11918034 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 9444167
        echo request: 1889399
        echo replies: 584468
IcmpMsg:
        InType0: 1889155
        InType3: 187293
        InType8: 584468
        InType11: 6
        OutType0: 584468
        OutType3: 9444167
        OutType8: 1889399
Tcp:
    18813082 active connections openings
    4846931381 passive connection openings
    5607773 failed connection attempts
    3518250 connection resets received
    1390 connections established
    34455232921 segments received
    33247960704 segments send out
    5199703 segments retransmited
    336 bad segments received.
    5451230 resets sent
Udp:
    49913161 packets received
    10313106 packets to unknown port received.
    0 packet receive errors
    80394255 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    644145 SYN cookies sent
    959562 SYN cookies received
    2466162 invalid SYN cookies received
    137927 resets received for embryonic SYN_RECV sockets
    42604 packets pruned from receive queue because of socket buffer overrun
    264535653 TCP sockets finished time wait in fast timer
    220604541 delayed acks sent
    57935 delayed acks further delayed because of locked socket
    Quick ack mode was activated 464190 times
    19930900 times the listen queue of a socket overflowed
    20575047 SYNs to LISTEN sockets dropped
    583296931 packets directly queued to recvmsg prequeue.
    22318496912 bytes directly in process context from backlog
    61715697205 bytes directly received in process context from prequeue
    1143572868 packet headers predicted
    428394541 packets header predicted and directly queued to user
    17148675211 acknowledgments not containing data payload received
    1150746411 predicted acknowledgments
    78437 times recovered from packet loss by selective acknowledgements
    Detected reordering 792 times using FACK
    Detected reordering 140 times using SACK
    13 congestion windows fully recovered without slow start
    1508 congestion windows recovered without slow start by DSACK
    78562 congestion windows recovered without slow start after partial ack
    TCPLostRetransmit: 85
    8685 timeouts after SACK recovery
    17263 timeouts in loss state
    107668 fast retransmits
    5422 forward retransmits
    106988 retransmits in slow start
    1123572 other TCP timeouts
    TCPLossProbes: 3576097
    TCPLossProbeRecovery: 2739122
    33851 SACK retransmits failed
    560581 packets collapsed in receive queue due to low socket buffer
    464239 DSACKs sent for old packets
    2760059 DSACKs received
    384 DSACKs for out of order packets received
    2730400 connections reset due to unexpected data
    670 connections reset due to early user close
    73606 connections aborted due to timeout
    TCPDSACKIgnoredOld: 38
    TCPDSACKIgnoredNoUndo: 2411844
    TCPSpuriousRTOs: 13679
    TCPSackShifted: 22916
    TCPSackMerged: 52018
    TCPSackShiftFallback: 151422
    TCPBacklogDrop: 2367
    TCPTimeWaitOverflow: 4515359237
    TCPReqQFullDoCookies: 961679
    TCPRetransFail: 929
    TCPRcvCoalesce: 622478541
    TCPOFOQueue: 454658
    TCPChallengeACK: 1496
    TCPSYNChallenge: 1239
    TCPSpuriousRtxHostQueues: 108
    TCPAutoCorking: 228220
    TCPFromZeroWindowAdv: 161
    TCPToZeroWindowAdv: 161
    TCPWantZeroWindowAdv: 11351
    TCPSynRetrans: 881703
    TCPOrigDataSent: 16716686250
    TCPHystartTrainDetect: 101183
    TCPHystartTrainCwnd: 2420580
    TCPHystartDelayDetect: 51
    TCPHystartDelayCwnd: 8943
    TCPACKSkippedSeq: 7836
    TCPACKSkippedTimeWait: 78
IpExt:
    InNoRoutes: 833
    InOctets: 6866883605112
    OutOctets: 5746004477869
    InNoECTPkts: 35447482267
    InECT0Pkts: 3272
    
   [root@93-44-159-aliyun-core logs]# dmesg -T | grep '12:40:5'
	[Sat May  8 12:40:51 2021] net_ratelimit: 2699 callbacks suppressed
	[Sat May  8 12:40:51 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:51 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:51 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:52 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] net_ratelimit: 2189 callbacks suppressed
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	[Sat May  8 12:40:57 2021] nf_conntrack: table full, dropping packet
	
	[root@93-44-159-aliyun-core logs]# sysctl -a | grep nf_conn
	net.netfilter.nf_conntrack_acct = 0
	net.netfilter.nf_conntrack_buckets = 65536
	net.netfilter.nf_conntrack_checksum = 1
	net.netfilter.nf_conntrack_count = 0
	net.netfilter.nf_conntrack_events = 1
	net.netfilter.nf_conntrack_events_retry_timeout = 15
	net.netfilter.nf_conntrack_expect_max = 1024
	net.netfilter.nf_conntrack_generic_timeout = 600
	net.netfilter.nf_conntrack_helper = 1
	net.netfilter.nf_conntrack_log_invalid = 0
	net.netfilter.nf_conntrack_max = 262144
	net.netfilter.nf_conntrack_timestamp = 0
	net.nf_conntrack_max = 262144
	
	
	[root@93-44-159-aliyun-core logs]# ip -s link show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:16:3e:08:b9:bb brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    7367887086237 35377694745 0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    6167526060846 32372059145 0       0       0       0
    
   
   [root@93-44-159-aliyun-core logs]# column -t /proc/net/dev
Inter-|  Receive        |            Transmit
face     |bytes         packets      errs      drop  fifo  frame  compressed  multicast|bytes  packets        errs         drop  fifo  colls  carrier  compressed
eth0:    7368006665631  35378264534  0         0     0     0      0           0                6167633157994  32372593093  0     0     0      0        0           0
lo:      35013948710    88375105     0         0     0     0      0           0                35013948710    88375105     0     0     0      0        0           0


	[root@93-44-159-aliyun-core logs]# echo "`sysctl -n net.netfilter.nf_conntrack_max` `sysctl -n net.netfilter.nf_conntrack_buckets`"| awk '{printf "%.2f\n",$1/$2}'
4.00

	[root@93-44-159-aliyun-core ~]# cat /proc/net/nf_conntrack	
	// f**k没现场了
	# 输出例：
	# ipv4     2 tcp      6 431999 ESTABLISHED src=10.0.13.67 dst=10.0.13.109 sport=63473 dport=22 src=10.0.13.109 dst=10.0.13.67 sport=22 dport=63473 [ASSURED] mark=0 secctx=system_u:object_r:unlabeled_t:s0 zone=0 use=2
	
	# 记录格式：
	# 网络层协议名、网络层协议编号、传输层协议名、传输层协议编号、记录失效前剩余秒数、连接状态（不是所有协议都有）
	# 之后都是 key=value 或 flag 格式，1 行里最多 2 个同名 key（如 src 和 dst），第 1 次出现的来自请求，第 2 次出现的来自响应
	
	# flag：
	# [ASSURED]  请求和响应都有流量
	# [UNREPLIED]  没收到响应，哈希表满的时候这些连接先扔掉


	```
	
	
疑问

1. dmesg显示丢包但ip看没dropped packets？
2. 


