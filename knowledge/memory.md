# 存储

ALU -> L0 寄存器(<1ns) -> L1 高速缓存(≈1ns) -> L2 高速缓存(≈3ns) -> L3 高速缓存(≈15ns) -> 主存(≈80ns)

> *3层* 高速缓存是工业实践的结果。

由于多层存储间速度差非常大，一般批量读取数据，即读一个缓存行（Cache Line）。缓存行越大，局部性空间效率越高，但读取慢；缓存行越小，局部性空间效率越低，但读取快。

> *64 Bytes* 缓存行是工业实践的结果。

由于 CPU 要符合 *缓存一致性协议*，即当 CPU 修改缓存行的数据后，内存中对应的缓存行失效，*CPU-主存*、*CPU-CPU* 间进行同步，有性能损耗。

> ConcurrentHashMap、Disruptor 的 RingBuffer 都通过填充缓存行避免了同步导致的性能损耗。





