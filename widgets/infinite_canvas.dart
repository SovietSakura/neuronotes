// widgets/infinite_canvas.dart
import 'package:flutter/material.dart';
import '../models/note.dart';

class InfiniteCanvas extends StatefulWidget {
  final List<NoteElement> elements;
  final Function(NoteElement) onElementTap;
  final Function(NoteElement) onElementMove;
  final Function(NoteElement) onElementResize;

  InfiniteCanvas({
    required this.elements,
    required this.onElementTap,
    required this.onElementMove,
    required this.onElementResize,
  });

  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  late TransformationController _transformationController;
  double _scale = 1.0;
  Offset _position = Offset.zero;
  
  // 拖动状态
  String? _draggingElementId;
  bool _isResizing = false;
  Offset _startDragPosition = Offset.zero;
  NoteElement? _selectedElement;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 4.0,
        child: Container(
          width: 5000,
          height: 5000,
          color: Colors.grey[100],
          child: Stack(
            children: [
              // 网格背景
              CustomPaint(
                painter: GridPainter(),
                size: Size(5000, 5000),
              ),
              // 笔记元素
              ...widget.elements.map((element) => Positioned(
                left: element.x,
                top: element.y,
                width: element.width,
                height: element.height,
                child: _buildElement(element),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElement(NoteElement element) {
    final bool isSelected = _selectedElement?.id == element.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = element;
        });
        widget.onElementTap(element);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )]
              : null,
        ),
        child: Stack(
          children: [
            // 内容
            Padding(
              padding: EdgeInsets.all(8.0),
              child: _buildElementContent(element),
            ),
            // 拖动手柄
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 24,
              child: GestureDetector(
                onPanStart: (details) => _startDrag(element, details.localPosition, false),
                onPanUpdate: (details) => _updateDrag(details.globalPosition),
                onPanEnd: (details) => _endDrag(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.drag_handle, size: 16, color: Colors.grey[600]),
                ),
              ),
            ),
            // 调整大小手柄
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                width: 24,
                height: 24,
                child: GestureDetector(
                  onPanStart: (details) => _startDrag(element, details.localPosition, true),
                  onPanUpdate: (details) => _updateDrag(details.globalPosition),
                  onPanEnd: (details) => _endDrag(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                        topLeft: Radius.circular(8),
                      ),
                    ),
                    child: Icon(Icons.open_in_full, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementContent(NoteElement element) {
    switch (element.type) {
      case 'text':
        return SingleChildScrollView(
          child: Text(
            element.data['text'] ?? '',
            style: TextStyle(fontSize: 16),
          ),
        );
      case 'image':
        return Image.file(
          File(element.data['path']),
          fit: BoxFit.contain,
        );
      case 'audio':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.audiotrack, size: 32, color: Colors.blue),
            SizedBox(height: 8),
            Text(element.data['text'] ?? 'Audio Recording', 
                 style: TextStyle(fontSize: 14)),
            // 这里可以添加播放控件
          ],
        );
      default:
        return Center(child: Text('Unknown element type'));
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _startDragPosition = details.focalPoint;
    
    // 检查是否点击了元素（而不是画布）
    if (_draggingElementId != null) return;
    
    _scale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // 如果正在拖动元素，不进行画布变换
    if (_draggingElementId != null) return;
    
    setState(() {
      // 处理缩放
      if (details.scale != 1.0) {
        _scale = details.scale;
        
        final double newScale = _transformationController.value.getMaxScaleOnAxis() * details.scale;
        if (newScale >= 0.1 && newScale <= 4.0) {
          // 计算缩放中心点
          final focalPointScene = _transformationController.toScene(details.localFocalPoint);
          
          // 应用缩放
          _transformationController.value = Matrix4.identity()
            ..translate(focalPointScene.dx, focalPointScene.dy)
            ..scale(newScale)
            ..translate(-focalPointScene.dx, -focalPointScene.dy);
        }
      }
      // 处理平移
      else if (details.focalPoint != _startDragPosition) {
        final delta = details.focalPoint - _startDragPosition;
        _startDragPosition = details.focalPoint;
        
        // 应用平移
        _transformationController.value.translate(
          delta.dx / _transformationController.value.getMaxScaleOnAxis(),
          delta.dy / _transformationController.value.getMaxScaleOnAxis(),
        );
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // 重置状态
    _scale = 1.0;
  }

  void _startDrag(NoteElement element, Offset localPosition, bool isResizing) {
    setState(() {
      _draggingElementId = element.id;
      _isResizing = isResizing;
      _startDragPosition = localPosition;
      _selectedElement = element;
    });
  }

  void _updateDrag(Offset globalPosition) {
    if (_draggingElementId == null) return;
    
    final element = widget.elements.firstWhere((e) => e.id == _draggingElementId);
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final Offset canvasPosition = _transformationController.toScene(localPosition);
    
    if (_isResizing) {
      // 调整大小
      final newWidth = element.width + (canvasPosition.dx - element.x - element.width);
      final newHeight = element.height + (canvasPosition.dy - element.y - element.height);
      
      if (newWidth >= 100 && newHeight >= 50) {
        final updatedElement = NoteElement(
          id: element.id,
          type: element.type,
          data: element.data,
          x: element.x,
          y: element.y,
          width: newWidth,
          height: newHeight,
        );
        
        widget.onElementResize(updatedElement);
      }
    } else {
      // 移动元素
      final updatedElement = NoteElement(
        id: element.id,
        type: element.type,
        data: element.data,
        x: canvasPosition.dx - _startDragPosition.dx,
        y: canvasPosition.dy - _startDragPosition.dy,
        width: element.width,
        height: element.height,
      );
      
      widget.onElementMove(updatedElement);
    }
  }

  void _endDrag() {
    setState(() {
      _draggingElementId = null;
      _isResizing = false;
    });
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 50.0;
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    // 绘制水平线
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // 绘制垂直线
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}