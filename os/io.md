# I/O

[toc]

## unp

### 随笔
#### 疑问

1. 1.2 read读到数据就停止，那数据不完整呢？为什么不读到EOF和超时才停止？
3. inet_addr, inet_ntoa, inet_pton, inet_ntop

#### 信息

1. tcp不提供记录结束标识，如以约定的EOF或协议头含长度信息。
2. 对于过长的记录，可以拒绝发送，或拆分小块再发送

## 异步实现与设计
### windows aio



### libevent

### libuv



## Reference
### OS

#### Concept

* 现代操作系统
* 深入理解计算机系统
* Unix高级环境编程
* Unix网络编程 * 2
* [C10K](http://www.kegel.com/c10k.html)
* [C10M](http://highscalability.com/blog/2013/5/13/the-secret-to-10-million-concurrent-connections-the-kernel-i.html)
* Linux 系统编程
* Linux/UNIX系统编程手册 https://book.douban.com/subject/25809330/
* http://igm.univ-mlv.fr/~yahya/progsys/linux.pdf
* https://github.com/0xAX/linux-insides/blob/master/SUMMARY.md
* https://dropbox.tech/infrastructure/optimizing-web-servers-for-high-throughput-and-low-latency
* http://www.brendangregg.com/linuxperf.html
* https://tldp.org/LDP/tlk/tlk.html
* https://lenovopress.com/redp4285.pdf
* https://planet.kernel.org/
* https://lwn.net/Kernel/Index/
* https://learnlinuxconcepts.blogspot.com/2014/10/this-blog-is-to-help-those-students-and.html
* See Schmidt et al, Pattern-Oriented Software Architecture, Volume 2 (POSA2)* Richard Stevens's networking books, Matt Welsh's SEDA framework, etc

#### Syscall

学习要点

* 用这些系统知识操作一下文件系统，实现一个可以拷贝目录树的小程序
* 用 fork / wait / waitpid 写一个多进程的程序，用 pthread 写一个多线程带同步或互斥的程序。比如，多进程购票的程序
* 用 signal / kill / raise / alarm / pause / sigprocmask 实现一个多进程间的信号量通信的程序

#### 异步I/O


### Network

#### TCP

http://www.saminiir.com/lets-code-tcp-ip-stack-1-ethernet-arp/
http://www.saminiir.com/lets-code-tcp-ip-stack-2-ipv4-icmpv4/
http://www.saminiir.com/lets-code-tcp-ip-stack-3-tcp-handshake/
http://www.saminiir.com/lets-code-tcp-ip-stack-4-tcp-data-flow-socket-api/
http://www.saminiir.com/lets-code-tcp-ip-stack-5-tcp-retransmission/



