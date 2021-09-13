# Bytebuddy

## Todos

* [ ] ByteBuddy ElementMatchers
* [x] JDK synthetic
* [ ] BootstrapInstrumentBoost
* [ ] AgentBuilder
* [x] PluginFinder
* [ ] JDK Instrumentation
* [ ] JDK java.lang.Runtime
* [ ] JDK SPI 机制
* [ ] JDK java.util.ServiceLoader
* [x] JDK 类加载器
* [ ] ByteBuddy TypeDescription
* [ ] JDK ManagementFactory.getRuntimeMXBean()
* [ ] JDK URLClassLoader
* [ ] ByteBuddy MethodDelegation
* [ ] Skywalking InterceptorInstanceLoader.load()
* [ ] 
	
## 类加载器

``` plantuml
@startuml
class BootstrapClassLoader
BootstrapClassLoader -> ExtClassLoader
ExtClassLoader -> AppClassLoader
AppClassLoader -> AgentClassLoader
@enduml
```

![](media/16310716646681.jpg)


``` java
public class AgentClassLoader extends ClassLoader {

    static {
        /*
         * Try to solve the classloader dead lock. See https://github.com/apache/skywalking/pull/2016
         */
        registerAsParallelCapable();
    }
```






