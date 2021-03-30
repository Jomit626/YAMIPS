# Yet Another MIPS System

## Game Programming Guide
`src/game/game.c` 是一个使用`4`个按键控制红色小人在屏幕上移动的示例游戏。  
在`main`函数中完成中断、屏幕以及游戏的初始化后，每隔`33.333ms`调用一次`game_loop`函数以实现`30fps`的画面。`game_loop`函数返回非`0`值后游戏推出。  
主要通过修改`game_init`和`game_loop`函数实现游戏。  

### 屏幕
系统画面的分辨率为`800x600`， 被划分成了多个`20x28`的小方格。  
使用`src/game/graphic.h`提供的`display_set_color`函数来设置方格颜色，用`display_set_image`来设置方格图案。  
方格坐标以屏幕左上角为起点，坐标X轴沿屏幕垂直方向，最大值为`(DISPLAY_HEIGHT - 1)`, 坐标Y轴沿屏幕水平方向，最大值为`(DISPLAY_WIDTH - 1)`。  
每个像素用2字节RGB表示， 0-3位为B， 4-7位位G， 8-11位位R。因为没有实现`lh`和`sh`半字操作，所以颜色用4字节表示，比如`0x00000000`为黑色，`0x0fff0fff`为白色，`0x0f000f00`为红色。  
方格的图案大小应为`(DISPLAY_IMAGE_SIZE_WORD * 4)`字节， 示例图案见`src/game/game.c`中`player_image`变量。  

### 按键输入
按键输入部分参考`src/game/game.c`中`game_loop`函数。  

### malloc
想动态申请内存请使用`src/game/fake_malloc.h`提供的虚假`malloc`函数， 功能非常简单， `free` 什么的不存在的。  

### 编程注意事项
没有实现`lh`、`sh`、`lb`、`sb`， 所以不能使用`char`和`short`等变量类型。  
没有实现整数乘法和除法语句， 请使用`src/math/math.h`中实现的乘除法函数。  
