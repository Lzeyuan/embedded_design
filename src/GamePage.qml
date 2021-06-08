import QtQuick 2.12
import QtQuick.Window 2.12
import QtMultimedia 5.14

import "qrc:/"

Item {
    // x:行， y:列
    // block_width_count必须为偶数
    property int block_width_count: 10
    property int block_height_count: 24
    property var mainRect_width_scale: 0.6
    property bool auxiliary_line_show: false
    property var block_width: mainRect.width/block_width_count
    property var block_height: mainRect.height/block_height_count
    property bool sound: true
    property alias timer: refreash_timer
    property alias background_music: background_music

    Item {
        id: root
        anchors.fill: parent
        property var blocks: null
        property var currentBlocks: null
        property int nextBlocks: 0
        property int currentBlocks_offset_x;
        property int currentBlocks_offset_y;
        property int score;

        property int none_type: 0
        property int i_type: 1
        property int o_type: 2
        property int z_type: 3
        property int l_type: 4
        property int t_type: 5

        //设置音频
        MediaPlayer {
            id: background_music
            source: "qrc:/music/game/background.mp3"
            loops: MediaPlayer.Infinite
        }

        MediaPlayer {
            id: button_music
            source: "qrc:/music/game/distance_button.wav"
        }

        property var blockTypes: [
            [[0, 1, 0, 0],
             [0, 1, 0, 0],
             [0, 1, 0, 0],
             [0, 1, 0, 0]],

            [[0, 0, 0, 0],
             [0, 1, 1, 0],
             [0, 1, 1, 0],
             [0, 0, 0, 0]],

            [[0, 1, 0, 0],
             [0, 1, 1, 0],
             [0, 0, 1, 0],
             [0, 0, 0, 0]],

            [[0, 1, 0, 0],
             [0, 1, 0, 0],
             [0, 1, 1, 0],
             [0, 0, 0, 0]],

            [[0, 0, 0, 0],
             [0, 1, 0, 0],
             [1, 1, 1, 0],
             [0, 0, 0, 0]]
        ]


        // 背景图
        Image {
            anchors.fill: root
            id: item_image_background
            source: "qrc:/img/gameUI/back3.jpg"
        }

        // UI布局
        // 方块窗口
        Rectangle {
            property int mainRect_width: Math.floor(parent.width*mainRect_width_scale)
            property int mainRect_height: Math.floor(parent.height-20)

            id: mainRect
            anchors.left: root.left
            anchors.top: root.top
            anchors.margins: 10
            width: mainRect_width - mainRect_width % block_width_count
            height: mainRect_height - mainRect_height % block_height_count
            focus: true

            Repeater {
                id: mainRect_item_repeater
                model: block_width_count * block_height_count
                delegate: block_component
            }

            Component {
                id: block_component
                Rectangle {
                    x: index%10*block_width
                    y: Math.floor(index/10)*block_height
                    width: block_width
                    height: block_height
                }
            }

            Canvas{
                id: mainRect_canvas
                width: parent.width
                height: parent.height

                onPaint: {
                    var ctx = getContext("2d");
                    draw_auxiliary_line(ctx)
                }

                function draw_auxiliary_line(ctx) {
                    // 画之前清空画布
                    ctx.clearRect(0, 0, mainRect.width, mainRect.height);

                    ctx.fillStyle ="black";           // 设置画笔属性
                    ctx.strokeStyle = "black";
                    ctx.lineWidth = 3

                    function draw_line(start_x, start_y, end_x, end_y) {
                        ctx.beginPath();                  // 开始一条路径
                        ctx.moveTo(start_x, start_y);         // 移动到指定位置
                        ctx.lineTo(end_x, end_y);
                        ctx.stroke()
                    }

                    draw_line(0, 0, mainRect.width, 0)
                    draw_line(0, 0, 0, mainRect.height)
                    draw_line(0, mainRect.height, mainRect.width, mainRect.height)
                    draw_line(mainRect.width, mainRect.height, mainRect.width, 0)


                    if (auxiliary_line_show) {
                        ctx.fillStyle ="gray";           // 设置画笔属性
                        ctx.strokeStyle = "gray";
                        ctx.setLineDash([1])    //虚线
                        ctx.lineWidth = 0.5
                        let line = null
                        for (line = 1; line < block_height_count ; line++) {
                            var line_y = line * block_height
                            draw_line(0, line_y, mainRect.width, line_y)
                        }

                        for (line = 1; line < block_width_count ; line++) {
                            var line_x = line * block_width
                            draw_line(line_x, 0, line_x, mainRect.height)
                        }


                        ctx.setLineDash([])    //实线，不写的话之后画实线，还是虚线，设置了[]也没用
                    }
                }
            }
        }

        // 下一个方块
        Image {
            id: next_block_rectangle
            anchors.top: parent.top
            anchors.left: mainRect.right
            anchors.right: parent.right
            anchors.margins: 10
            height: root.height/4
            source: "qrc:/img/gameUI/next.png"

            Canvas {
                property var next_width: parent.width/6
                property var next_height: parent.height/6
                property var offset_x: 5
                id: next_block_canvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, parent.width, parent.height);
                    ctx.strokeStyle = "black";
                    ctx.lineWidth = 1
                    console.log(root.nextBlocks)
                    switch (root.nextBlocks + 1) {
                    case root.i_type:
                        drawI(ctx);
                        break;
                    case root.o_type:
                        drawO(ctx);
                        break;
                    case root.z_type:
                        drawZ(ctx)
                        break;
                    case root.l_type:
                        drawL(ctx)
                        break;
                    case root.t_type:
                        drawT(ctx)
                        break;
                    default:
                        break;
                    }
                }

                // x: 列， y: 行
                function drawI(ctx) {
                    draw_rectangle_vertical(ctx, 1, 4, 4)
                }

                function drawO(ctx) {
                    draw_rectangle_horizontal(ctx, 2, 2, 2)
                    draw_rectangle_horizontal(ctx, 2, 2, 2, 1)
                }

                function drawZ(ctx) {
                    draw_rectangle_vertical(ctx, 2, 3, 2)
                    draw_rectangle_vertical(ctx, 2, 3, 2, 1, 1)
                }

                function drawL(ctx) {
                    draw_rectangle_vertical(ctx, 2, 3, 2)
                    draw_rectangle_horizontal(ctx, 2, 3, 2, 2)
                }

                function drawT(ctx) {
                    draw_rectangle_vertical(ctx, 3, 2, 1, 1)
                    draw_rectangle_horizontal(ctx, 3, 2, 3, 1)
                }

                // 画横向矩形
                function draw_rectangle_horizontal(ctx, width_count, height_count, quantity, height_offset = 0, width_offset = 0) {
                    var block_size = Math.min(next_width, next_height)
                    for (var i = 0; i < quantity; i++) {
                        draw_rectangle(ctx, (parent.width - block_size * width_count)/2 + block_size * (width_offset + i),
                                       (parent.height - block_size * height_count)/2 + block_size * height_offset + offset_x,
                                       block_size,
                                       block_size);
                    }
                }

                // 画纵向矩形
                function draw_rectangle_vertical(ctx, width_count, height_count, quantity, width_offset = 0, height_offset = 0) {
                    var block_size = Math.min(next_width, next_height)
                    for (var i = 0; i < quantity; i++) {
                        draw_rectangle(ctx, (parent.width - block_size * width_count)/2 + block_size * width_offset,
                                       (parent.height - block_size * height_count)/2 + block_size * (height_offset + i) + offset_x,
                                       block_size,
                                       block_size);
                    }
                }

                function draw_rectangle(ctx, start_x, start_y, rect_width, rect_height, rect_colot = "green") {
                    ctx.fillStyle = rect_colot
                    ctx.fillRect(start_x, start_y,
                                 rect_width, rect_height);    //填充
                    ctx.strokeRect(start_x, start_y,
                                   rect_width, rect_height);  //描边
                }
            }
        }

        // 得分
        Image {
            id: scoreBlock
            anchors.top: next_block_rectangle.bottom
            anchors.left: mainRect.right
            anchors.right: parent.right
            anchors.margins: 10
            height: 50
            source : "qrc:/img/gameUI/score.png"


            Text {
                anchors.centerIn: parent
                text: root.score
                font.pixelSize: parent.height-10
                color: "black"
            }
        }

        // 初始化
        Component.onCompleted: {
            blocks = new Array(block_height_count);
            for(var i = 0;i < block_height_count; i++){
                blocks[i] = new Array(block_width_count);
                for(var j = 0;j < block_width_count; j++){
                    blocks[i][j] = 0;
                }
            }
            root.currentBlocks = root.blockTypes[Math.floor(Math.random()*root.blockTypes.length)];
            root.nextBlocks = Math.floor(Math.random()*root.blockTypes.length);
        }

        // 键盘监听
        Keys.onPressed: {
            if (refreash_timer.running) {
                if(event.key === Qt.Key_Left){
                    root.moveLeft();
                } else if(event.key === Qt.Key_Right){
                    root.moveRight();
                } else if(event.key === Qt.Key_Up){
                    root.rotate();
                } else if(event.key === Qt.Key_Down){
                    root.moveBottom();
                }
            }
            if (event.key === Qt.Key_Escape) {
                if (refreash_timer.running) refreash_timer.stop()
                else refreash_timer.start()
            }
        }

        // 手势控制
        MultiPointTouchArea {
            anchors.fill: parent
            mouseEnabled: true
            minimumTouchPoints: 1
            maximumTouchPoints: 1
            property var tracer: []

            touchPoints: [
                TouchPoint {
                    id: point
                }
            ]

            onReleased: {
                if (refreash_timer.running){
                    if(Math.abs(point.startX-point.x) > Math.abs(point.startY-point.y)) {
                        if(point.x > point.startX) {
                            root.moveRight()
                        } else {
                            root.moveLeft()
                        }
                    } else {
                        if(point.y > point.startY) {
                            root.moveBottom()
                        } else {
                            root.rotate()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: game_function_menu
            anchors.fill: parent
            visible: false
            color:"#7F000000"
            Image {
                anchors.centerIn:  parent
                width: parent.width/2
                height: parent.height/6
                source: "qrc:/img/gameUI/item_back.png"
            }

            Grid {
                anchors.centerIn: parent
                spacing: 10
                rows: 1
                columns: 3

                // 返回主菜单
                GameButton {
                    width: 30
                    height: width
                    source: "qrc:/img/gameUI/home.png"
                    onClicked: {
                        console.log("按下了按钮")
                    }
                }

                // 辅助线按钮
                GameButton {
                    width: 30
                    height: width
                    source: "qrc:/img/gameUI/grid.png"
                    onClicked: {
                        button_music.play()
                        auxiliary_line_show = !auxiliary_line_show
                        mainRect_canvas.requestPaint()
                    }
                }

                // 开关音乐
                GameButton {
                    id: sound_button
                    width: 30
                    height: width
                    source: "qrc:/img/gameUI/sound.png"
                    onClicked: {
                        if (sound) {
                            sound = !sound
                            button_music.volume = 0
                            background_music.pause()
                            sound_button.source = "qrc:/img/gameUI/mute.png"
                            console.log("关闭声音！")
                        } else {
                            sound = !sound
                            button_music.volume = 1
                            background_music.play()
                            sound_button.source = "qrc:/img/gameUI/sound.png"
                            console.log("打开声音！")
                        }

                    }
                }
            }
        }

        // 菜单键
        Rectangle{
            id: mainRect_button_home
            anchors.right: root.right
            anchors.bottom: root.bottom
            anchors.margins: 10
            height: 30
            width: 30
            color: "transparent"


            Image {
                anchors.fill: parent
                source: "qrc:/img/gameUI/function.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    button_music.play()
                    console.log(game_function_menu.visible)
                    if (!game_function_menu.visible) {
                        // 显示菜单
                        game_function_menu.visible = !game_function_menu.visible
                        refreash_timer.stop()
                    } else {
                        // 关闭菜单
                        game_function_menu.visible = !game_function_menu.visible
                        refreash_timer.start()
                    }
                }
            }
        }

        // 刷新屏幕
        Timer {
            id: refreash_timer
            interval: 500
            repeat: true
            running: true
            onTriggered: {
                if (root.currentBlocks == null || !root.moveDown()) {
                    if (root.currentBlocks !== null) {
                        root.eraseBlocks()
                    }
                    root.createNewBlocks()
                    next_block_canvas.requestPaint()
                }
                root.refresh()
            }
        }

        // 刷新屏幕
        function refresh(){
            for(var row = 0;row < block_height_count; row++){
                for (var col = 0; col < block_width_count; col++) {
                    var index = row*10 + col
                    if(equal_array(root.blocks, row, col, 1)){
                        mainRect_item_repeater.itemAt(index).border.width = 1;
                        mainRect_item_repeater.itemAt(index).border.color = "black";
                        mainRect_item_repeater.itemAt(index).color = "#2E64FE";
                    } else if(root.inside_is_currentBlocks(row, col)){
                        mainRect_item_repeater.itemAt(index).color = "green";
                        mainRect_item_repeater.itemAt(index).border.width = 1;
                        mainRect_item_repeater.itemAt(index).border.color = "black";
                    }else {
                        mainRect_item_repeater.itemAt(index).color = "#000000";
                        mainRect_item_repeater.itemAt(index).border.width = 0;
                    }
                }
            }
        }

        // 创建新方块
        function createNewBlocks(){
            root.currentBlocks = root.blockTypes[root.nextBlocks]
            root.nextBlocks = Math.floor(Math.random()*root.blockTypes.length);

            root.currentBlocks_offset_x = 0;
            root.currentBlocks_offset_y = 0;
            if (!isOverlap(root.currentBlocks , 1, 0)) {
                console.log("game_over create")
                refreash_timer.stop()
            }
        }

        // 方块下落
        function moveDown(){
            if(isOverlap(currentBlocks, 1, 0)){
                root.currentBlocks_offset_x += 1;
                return true;
            } else {
                var max_offset_horizontal = (block_width_count-4)/2
                for(var i = 0;i < 4; i++){
                    for (var j = 0; j < 4; j++) {
                        if(root.currentBlocks[i][j] === 1){
                            var x = i + root.currentBlocks_offset_x - 2
                            var y = j + root.currentBlocks_offset_y + max_offset_horizontal
                            root.blocks[x][y] = 1
                        }
                    }
                }
                return false;
            }
        }

        // 判断越界
        function isOverlap(tempBlocks, offset_x, offset_y){
            if(tempBlocks === null){
                return false
            }

            // 类似BVH
            var minRow = 3;
            var maxRow = 0;
            var minCol = 3;
            var maxCol = 0;
            for(var i = 0;i < 4;i++){
                for (var j = 0; j < 4; j++) {
                    if(tempBlocks[i][j] === 1){
                        minRow = Math.min(minRow, i);
                        maxRow = Math.max(maxRow, i);
                        minCol = Math.min(minCol, j);
                        maxCol = Math.max(maxCol, j);
                    }
                }
            }

            // X轴越界
            // next方块index为[3][3],取[0][1] ([row][col]) 为锚点
            // 方块启示显示从第二行[1]开始，为方便计算，index + 2，游戏y轴范围变为[0, block_height_count + 1]
            // 起点为0（本身占一行），加上方块最大行数，再加上位移值，即:
            // root.currentBlocks_offset_x + 2 + maxRow + offset_x  >= block_height_count + 2
            if(root.currentBlocks_offset_x + maxRow - 2 + offset_x  >= block_height_count){
                return false
            }

            // Y轴越界
            // 方块占4x4格，初始位置在[block_width_count/2-2,block_width_count/2+1]
            // 左右最多位移(block_width_count-4)/2格
            var max_offset_horizontal = (block_width_count-4)/2
            // 左移：root.currentBlocks_offset_x + minCol + max_offset_horizontal + offset_x（为负数） < 0
            // 右移：(3 - maxCol) + max_offset_horizontal < root.currentBlocks_offset_x + offset_x
            if(root.currentBlocks_offset_y + minCol + max_offset_horizontal + offset_y < 0 ||
                    (3 - maxCol) + max_offset_horizontal < root.currentBlocks_offset_y + offset_y){
                return false
            }

            // 判断是否已有方块
            for (var row = 0; row < 4; row++) {
                for (var col = 0; col < 4; col++) {
                    if (equal_array(tempBlocks, row, col, 1) &&
                            equal_array(root.blocks,
                                        root.currentBlocks_offset_x - 2 + row + offset_x,
                                        root.currentBlocks_offset_y + max_offset_horizontal
                                        + col + offset_y, 1)) {
                        return false
                    }

                }
            }
            return true;
        }

        // 判断二维数组越界，值比较
        function equal_array(array, x, y, key = null) {
            if (x < 0 || y < 0) return false;
            if (array[x] !== undefined) {
                try{
                    if (array[x][y] !== undefined) {
                        if (key !== null) {
                            return array[x][y] === key
                        } else {
                            return ture;
                        }
                    }
                } catch(err) {

                    console.log(err.description, x,y, array)
                }
            }
            return false;
        }

        // 测试当前格子是否有可以动的方块currentBlocks
        // 位于currentBlocks中的行位置 = 当前坐标x - (行位移量 - 2)
        // 位于currentBlocks中的列位置 = 当前坐标y - (max_offset_horizontal + currentBlocks_offset_y)
        function inside_is_currentBlocks(x, y) {
            var max_offset_horizontal = (block_width_count-4)/2
            var row = x - (root.currentBlocks_offset_x - 2)
            var col = y - (root.currentBlocks_offset_y + max_offset_horizontal)
            if (equal_array(root.currentBlocks, row, col, 1)) {
                return true
            }
            return false;
        }

        // 左移
        function moveLeft(){
            if(root.currentBlocks == null){
                return false;
            }
            button_music.play()
            if(isOverlap(currentBlocks, 0, -1)){
                currentBlocks_offset_y -= 1;
                refresh();
                return true;
            } else {
                return false;
            }
        }

        // 右移
        function moveRight(){
            if(root.currentBlocks == null){
                return false;
            }
            button_music.play()
            if(isOverlap(currentBlocks, 0, 1)){
                root.currentBlocks_offset_y += 1;
                refresh();
                return true;
            } else {
                return false;
            }
        }

        // 下移
        function moveBottom(){
            if(root.currentBlocks == null){
                return false;
            }
            button_music.play()
            if(isOverlap(currentBlocks, 1, 0)){
                root.currentBlocks_offset_x += 1;
                refresh();
                return true;
            } else {
                return false;
            }
        }

        // 旋转
        // 先上下对半交换，然后转置，耗费空间为0
        // 可惜这里不能更改原素组
        function rotate(){
            button_music.play()
            var tempArray = new Array(currentBlocks.length);
            for (var i = 0; i < tempArray.length; i++) {
                tempArray[i] = new Array(currentBlocks[0].length)
                for (var j = 0; j < currentBlocks[0].length; j++) {
                    tempArray[i][j] = currentBlocks[i][j]
                }
            }

            for (var row = 0; row < Math.floor(tempArray.length/2); row++) {
                for (var col = 0; col < tempArray[0].length; col++) {
                    var temp = tempArray[row][col]
                    tempArray[row][col] = tempArray[tempArray.length - 1 - row][col]
                    tempArray[tempArray.length - 1 - row][col] = temp
                }
            }
            for (var row = 0; row < tempArray.length; row++) {
                for (var col = row; col < tempArray[0].length; col++) {
                    var temp = tempArray[row][col]
                    tempArray[row][col] = tempArray[col][row]
                    tempArray[col][row] = temp
                }
            }

            if(isOverlap(tempArray, 0, 0)){
                currentBlocks = tempArray;
                refresh();
                return true;
            } else {
                return false;
            }
        }

        // 消除完成的方块
        function eraseBlocks(){
            var eraseCount = 0;
            for(var i = block_height_count - 1; i >= 0;i--){
                var complete = true;
                var empty = true;
                for(var j = 0; j < block_width_count; j++){
                    if(blocks[i][j] === 0){
                        complete = false;
                    } else {
                        empty = false;
                    }
                }

                // 改行完成则记录完成数+1
                // 若没完成，移动覆盖方块
                if(complete){
                    eraseCount++;
                } else if (eraseCount > 0){
                    for(j = 0;j < block_width_count;j ++) {
                        blocks[i+eraseCount][j] = blocks[i][j];
                        blocks[i][j] = 0;       // 不写的话，消除多行方块会导致有几行方块绘图不会更新
                    }
                }
                if(empty === true){
                    break
                }
            }

            // 计算得分
            if(eraseCount > 0){
                score += eraseCount*2-1;
            }
        }
    }
}
