# 大数据相关面试题整理

* [Java相关](#java相关)
    * [Java中"equals()"和"=="的区别](#java中equals和的区别)
    * [Java中"&gt;&gt;&gt;"和"&gt;&gt;"的区别](#java中和的区别)
    * [HashMap()在Java中的底层实现](#hashmap在java中的底层实现)
    * [Java线程的6种状态及切换](#java线程的6种状态及切换)
* [大数据组件相关](#大数据组件相关)
    * [Spark和MR的区别](#spark和mr的区别)

## Java相关

### Java中"equals()"和"=="的区别

```
最主要的区别是"=="是一个运算符而"equals()"是一个方法。此外，"=="是用来比较两个objects的引用(或地址)，即两个被比较的两个objects是不是存储在相同的memory location里的，而"equals()"是用来比较两个objects的内容。
```

### Java中">>>"和">>"的区别

```
">>>"叫做unsigned right bit-shift operator，它和">>"的差别仅仅体现在当我们对一个负数进行操作时。如果最高有效位(most significant bit)为1，即为负数，那么在执行">>"操作的时，会将"1"移入最高有效位，而不是"0"，但如果是执行">>>"操作，那么不管原来最高有效位上是不是1，都会移入一个"0"到最高有效位上。
```

**Example:**

假设我们要求(1 + 2147483647)的均值，即(1 + 2147483647) / 2：

```java
(1 + 2147483647) / 2 = 2147483648 / 2 = 1073741824
```

Now, with the code `(low + high) / 2`, these are the bits involved:

```java
          1: 00000000 00000000 00000000 00000001
+2147483647: 01111111 11111111 11111111 11111111
================================================
-2147483648: 10000000 00000000 00000000 00000000  // Overflow
/2
================================================
-1073741824: 11000000 00000000 00000000 00000000  // Signed divide, same as >> 1.
```

Let's make the "shift" to `>>>`:

```java
          1: 00000000 00000000 00000000 00000001
+2147483647: 01111111 11111111 11111111 11111111
================================================
-2147483648: 10000000 00000000 00000000 00000000  // Overflow
>>> 1
================================================
+1073741824: 01000000 00000000 00000000 00000000  // Unsigned shift right.
```

### HashMap()在Java中的底层实现

#### 构造函数：

HashMap提供了三个构造函数：
**HashMap()**：构造一个具有默认初始容量 (16) 和默认加载因子 (0.75) 的空 HashMap。
**HashMap(int initialCapacity)**：构造一个带指定初始容量和默认加载因子 (0.75) 的空 HashMap。
**HashMap(int initialCapacity, float loadFactor)**：构造一个带指定初始容量和加载因子的空HashMap。
在这里提到了两个参数：**初始容量**，**加载因子**。这两个参数是影响HashMap性能的重要参数，其中容量表示哈希表中桶的数量，初始容量是创建哈希表时的容量，加载因子是哈希表在其容量自动增加之前可以达到多满的一种尺度，它衡量的是一个散列表的空间的使用程度，负载因子越大表示散列表的装填程度越高，反之愈小。对于使用链表法的散列表来说，查找一个元素的平均时间是O(1+a)，因此如果负载因子越大，对空间的利用更充分，然而后果是查找效率的降低；如果负载因子太小，那么散列表的数据将过于稀疏，对空间造成严重浪费。系统默认负载因子为0.75，一般情况下我们是无需修改的。

#### 数据结构

![img](https://images0.cnblogs.com/blog/381060/201401/152128351581.png)

从上图我们可以看出HashMap底层实现还是数组，只是数组的每一项都是一条链。其中参数initialCapacity就代表了该数组的长度。

```java
public HashMap(int initialCapacity, float loadFactor) {
  //初始容量不能<0
  if (initialCapacity < 0)
    throw new IllegalArgumentException("Illegal initial capacity: "
                                       + initialCapacity);
  //初始容量不能 > 最大容量值，HashMap的最大容量值为2^30
  if (initialCapacity > MAXIMUM_CAPACITY)
    initialCapacity = MAXIMUM_CAPACITY;
  //负载因子不能 < 0
  if (loadFactor <= 0 || Float.isNaN(loadFactor))
    throw new IllegalArgumentException("Illegal load factor: "
                                       + loadFactor);

  // 计算出大于 initialCapacity 的最小的 2 的 n 次方值。
  int capacity = 1;
  while (capacity < initialCapacity)
    capacity <<= 1;

  this.loadFactor = loadFactor;
  //设置HashMap的容量极限，当HashMap的容量达到该极限时就会进行扩容操作
  threshold = (int) (capacity * loadFactor);
  //初始化table数组
  table = new Entry[capacity];
  init();
}
```

从源码中可以看出，每次新建一个HashMap时，都会初始化一个table数组。table数组的元素为Entry节点。

```java
static class Entry<K,V> implements Map.Entry<K,V> {
  final K key;
  V value;
  Entry<K,V> next;
  final int hash;

  /**
         * Creates new entry.
         */
  Entry(int h, K k, V v, Entry<K,V> n) {
    value = v;
    next = n;
    key = k;
    hash = h;
  }
  .......
}
```

其中```Entry```为HashMap的内部类，它包含了键key、值value、下一个节点next，以及hash值，这是非常重要的，正是由于Entry才构成了table数组的项为链表。

#### 存储实现

源码：

```java
public V put(K key, V value) {
  //当key为null，调用putForNullKey方法，保存null与table第一个位置中，这是HashMap允许为null的原因
  if (key == null)
    return putForNullKey(value);
  //计算key的hash值
  int hash = hash(key.hashCode());                  ------(1)
    //计算key hash 值在 table 数组中的位置
    int i = indexFor(hash, table.length);             ------(2)
    //从i出开始迭代 e,找到 key 保存的位置
    for (Entry<K, V> e = table[i]; e != null; e = e.next) {
      Object k;
      //判断该条链上是否有hash值相同的(key相同)
      //若存在相同，则直接覆盖value，返回旧value
      if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
        V oldValue = e.value;    //旧值 = 新值
        e.value = value;
        e.recordAccess(this);
        return oldValue;     //返回旧值
      }
    }
  //修改次数增加1
  modCount++;
  //将key、value添加至i位置处
  addEntry(hash, key, value, i);
  return null;
}
```

通过源码我们可以清晰看到HashMap保存数据的过程为：首先判断key是否为null，若为null，则直接调用putForNullKey方法。若不为空则先计算key的hash值，然后根据hash值搜索在table数组中的索引位置，如果table数组在该位置处有元素，则通过比较是否存在相同的key，若存在则覆盖原来key的value，否则将该元素保存在链头（最先保存的元素放在链尾）。若table在该处没有元素，则直接保存。这个过程看似比较简单，其实深有内幕。有如下几点：

* 先看迭代处。此处迭代原因就是为了防止存在相同的key值，若发现两个hash值（key）相同时，HashMap的处理方式是用新value替换旧value，这里并没有处理key，这就解释了HashMap中没有两个相同的key。
* 在看（1）、（2）处。这里是HashMap的精华所在。首先是hash方法，该方法为一个纯粹的数学计算，就是计算h的hash值。

```java
static int hash(int h) {
  h ^= (h >>> 20) ^ (h >>> 12);
  return h ^ (h >>> 7) ^ (h >>> 4);
}
```

我们知道对于HashMap的table而言，**数据分布需要均匀**（最好每项都只有一个元素，这样就可以直接找到），不能太紧也不能太松，太紧会导致查询速度慢，太松则浪费空间。计算hash值后，怎么才能保证table元素分布均与呢？我们会想到取模，但是由于**取模的消耗较大**，HashMap是这样处理的：调用```indexFor```方法。

```java
static int indexFor(int h, int length) {
  return h & (length-1);
}
```

**HashMap的底层数组长度总是2的n次方**，在构造函数中存在：capacity <<= 1;这样做总是能够保证HashMap的底层数组长度为2的n次方。当length为2的n次方时，**h&(length - 1)就相当于对length取模**，而且速度比直接取模快得多，这是HashMap在速度上的一个优化。至于为什么是2的n次方下面解释。

我们回到indexFor方法，该方法仅有一条语句：h&(length - 1)，这句话除了上面的取模运算外还有一个非常重要的责任：**均匀分布table数据和充分利用空间**。

这里我们假设length为16(2^n)和15，h为5、6、7。

![img](https://images0.cnblogs.com/blog/381060/201401/152128360645.jpg)

当n=15时，6和7的结果一样，这样表示他们在table存储的位置是相同的，也就是产生了碰撞，6、7就会在一个位置形成链表，这样就会导致查询速度降低。诚然这里只分析三个数字不是很多，那么我们就看0-15。

![img](https://images0.cnblogs.com/blog/381060/201401/152128371892.jpg)

从上面的图表中我们看到总共发生了8此碰撞，同时发现浪费的空间非常大，有1、3、5、7、9、11、13、15处没有记录，也就是没有存放数据。这是因为他们在与14进行&运算时，得到的结果最后一位永远都是0，即0001、0011、0101、0111、1001、1011、1101、1111位置处是不可能存储数据的，空间减少，进一步增加碰撞几率，这样就会导致查询速度慢。而当length = 16时，length – 1 = 15 即1111，那么进行低位&运算时，值总是与原来hash值相同，而进行高位运算时，其值等于其低位值。**所以说当length = 2^n时，不同的hash值发生碰撞的概率比较小，这样就会使得数据在table数组中分布较均匀，查询速度也较快。**

**综上所述**，HashMap的put流程为：当我们想一个HashMap中添加一对key-value时，系统首先会计算key的hash值，然后根据hash值确认在table中存储的位置。若该位置没有元素，则直接插入。否则迭代该处元素链表并依此比较其key的hash值。如果两个hash值相等且key值相等```(e.hash == hash && ((k = e.key) == key || key.equals(k)))```,则用新的Entry的value覆盖原来节点的value。如果两个hash值相等但key值不等 ，则将该节点插入该链表的链头。具体的实现过程见addEntry方法，如下：

```java
void addEntry(int hash, K key, V value, int bucketIndex) {
  //获取bucketIndex处的Entry
  Entry<K, V> e = table[bucketIndex];
  //将新创建的 Entry 放入 bucketIndex 索引处，并让新的 Entry 指向原来的 Entry 
  table[bucketIndex] = new Entry<K, V>(hash, key, value, e);
  //若HashMap中元素的个数超过极限了，则容量扩大两倍
  if (size++ >= threshold)
    resize(2 * table.length);
}
```

#### 读取实现：get(key)

相对于HashMap的存而言，取就显得比较简单了。通过key的hash值找到在table数组中的索引处的Entry，然后返回该key对应的value即可。

```java
public V get(Object key) {
  // 若为null，调用getForNullKey方法返回相对应的value
  if (key == null)
    return getForNullKey();
  // 根据该 key 的 hashCode 值计算它的 hash 码  
  int hash = hash(key.hashCode());
  // 取出 table 数组中指定索引处的值
  for (Entry<K, V> e = table[indexFor(hash, table.length)]; e != null; e = e.next) {
    Object k;
    //若搜索的key与查找的key相同，则返回相对应的value
    if (e.hash == hash && ((k = e.key) == key || key.equals(k)))
      return e.value;
  }
  return null;
}
```

在这里能够根据key快速的取到value除了和HashMap的数据结构密不可分外，还和Entry有莫大的关系，在前面就提到过，HashMap在存储过程中并没有将key，value分开来存储，而是当做一个整体key-value来处理的，这个整体就是Entry对象。同时value也只相当于key的附属而已。在存储的过程中，系统根据key的hashcode来决定Entry在table数组中的存储位置，在取的过程中同样根据key的hashcode取出相对应的Entry对象。

### Java线程的6种状态及切换

> Java中的线程状态分为6种：
>
> 1. **初始(NEW)**：新创建了一个线程对象，但还没有调用start()方法。
> 2. **运行(RUNNABLE)**：Java线程中将就绪（ready）和运行中（running）两种状态笼统的称为“运行”。
>   线程对象创建后，其他线程(比如main线程）调用了该对象的start()方法。该状态的线程位于可运行线程池中，等待被线程调度选中，获取CPU的使用权，此时处于就绪状态（ready）。就绪状态的线程在获得CPU时间片后变为运行中状态（running）。
> 3. **阻塞(BLOCKED)**：表示线程阻塞于锁。
> 4. **等待(WAITING)**：进入该状态的线程需要等待其他线程做出一些特定动作（通知或中断）。
> 5. **超时等待(TIMED_WAITING)**：该状态不同于WAITING，它可以在指定的时间后自行返回。
> 6. **终止(TERMINATED)**：表示该线程已经执行完毕。

![img](http://static.oschina.net/uploads/space/2013/0621/174442_0BNr_182175.jpg)

**1.** **新建(new)**：新创建了一个线程对象。

**2.** **可运行(runnable)**：线程对象创建后，其他线程(比如main线程）调用了该对象的start()方法。该状态的线程位于可运行线程池中，等待被线程调度选中，获取cpu 的使用权 。

**3.** **运行(running)**：可运行状态(runnable)的线程获得了cpu 时间片（timeslice） ，执行程序代码。

**4.** **阻塞(block)**：阻塞状态是指线程因为某种原因放弃了cpu 使用权，也即让出了cpu timeslice，暂时停止运行。直到线程进入可运行(runnable)状态，才有机会再次获得cpu timeslice 转到运行(running)状态。阻塞的情况分三种： 

(一). 等待阻塞：运行(running)的线程执行o.wait()方法，JVM会把该线程放入等待队列(waitting queue)中。

(二). 同步阻塞：运行(running)的线程在获取对象的同步锁时，若该同步锁被别的线程占用，则JVM会把该线程放入锁池(lock pool)中。

(三). 其他阻塞：运行(running)的线程执行Thread.sleep(long ms)或[t.join()][1]方法，或者发出了I/O请求时，JVM会把该线程置为阻塞状态。当sleep()状态超时、join()等待线程终止或者超时、或者I/O处理完毕时，线程重新转入可运行(runnable)状态。

**5.** **死亡(dead)**：线程run()、main() 方法执行结束，或者因异常退出了run()方法，则该线程结束生命周期。死亡的线程不可再次复生。

## 大数据组件相关

### Spark和MR的区别























## Reference

[1]:https://www.geeksforgeeks.org/joining-threads-in-java/
