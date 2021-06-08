import QtQuick 2.9
import QtQuick.Controls 2.0

//Image {
//    signal clicked();
//    property url image_Url

//    width: 50
//    height: width
//    source: image_Url

//    MouseArea {
//        id: area
//        anchors.fill: parent;

//        onClicked: {
//            console.log(root.clicked)
//            root.clicked();
//        }  //点击时触发自定义点击信号
//    }
//}


Rectangle {
    id: root
    property alias textItem: t      //导出Text实例，方便外部直接修改
    property alias text: t.text     //导出文本
    property alias source: image.source

    signal clicked();               //自定义点击信号
    color: "transparent"

    Image {
        id: image
        anchors.fill: parent
        source: "file"
    }

    Text {
        id: t
        //默认坐标居中
        anchors.centerIn: parent
        //默认文字对齐方式为水平和垂直居中
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        //默认宽度为parent的宽度，这样字太长超出范围时自动显示省略号
        width: parent.width
    }


    MouseArea {
        id: area
        anchors.fill: parent;
        onClicked: root.clicked();  //点击时触发自定义点击信号
    }
}
