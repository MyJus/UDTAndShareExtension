# UDTAndShareExtension
1、说明：预想的是实现iOS UDT和shareExtension。暂时只是实现shareExtension，UDT在尝试阶段

分享扩展功能应该算是完成了。使用的时候记得设置一下App Group。因为利用的是AppGroup userDefaults进行的传值。
另外说一下这个shareExtensionDemo主要做了些什么，这个demo主要做了：自定义分享界面 -> 存储将要分享的数据（主要存储的URL或String地址） -> 唤起container APP -> 判断唤是否起来自分享扩展 -> 处理数据（进行你想要的分享处理）

分享界面引用自定义的控制器，选择图片时，展示图片利用循环滚动。
因为图片是从相册加载的，所以又对图片进行了重绘和有损压缩，让内存的占用降低
