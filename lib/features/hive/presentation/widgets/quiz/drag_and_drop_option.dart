import 'package:flutter/material.dart';

import '../../../domain/models/course.dart';
import '../../../domain/models/quiz_page_state.dart';

class DragAndDropOptions extends StatelessWidget {
  final DragAndDropQuestion question;
  final Map<String, List<int>> droppedItems;
  final Function(String group, int itemIndex) onItemDropped;
  final QuizPageState state;
  final bool? Function(int itemIndex) isItemCorrect;

  const DragAndDropOptions({
    super.key,
    required this.question,
    required this.droppedItems,
    required this.onItemDropped,
    required this.isItemCorrect,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate which items are still in the "pool" (not dropped anywhere yet)
    Set<int> allDroppedIndices = {};
    for (var list in droppedItems.values) {
      allDroppedIndices.addAll(list);
    }

    List<int> poolIndices = [];
    for (int i = 0; i < question.items.length; i++) {
      if (!allDroppedIndices.contains(i)) {
        poolIndices.add(i);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // --- The Draggable Items Pool ---
        Text("Items:", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: poolIndices.map((index) {
            return _buildDraggableItem(context, index);
          }).toList(),
        ),

        const Divider(height: 32),

        // --- The Drop Zones (Groups) ---
        ...question.groups.keys.map((groupName) {
          final itemsInThisGroup = droppedItems[groupName] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DragTarget<int>(
              onWillAcceptWithDetails: (data) =>
                  !state.isChecked, // Disable drag if checked
              onAcceptWithDetails: (itemIndex) {
                onItemDropped(groupName, itemIndex.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isHovering ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (itemsInThisGroup.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Drop items here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          // Items inside the drop zone are also draggable (to move to another group)
                          children: itemsInThisGroup.map((index) {
                            return _buildDraggableItem(
                              context,
                              index,
                              isInDropZone: true,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDraggableItem(
    BuildContext context,
    int index, {
    bool isInDropZone = false,
  }) {
    final itemText = question.items[index];

    // Basic visual for the item card
    Widget itemCard(bool isDragging) {
      Color bgColor = isDragging ? Colors.blue.withOpacity(0.5) : Colors.white;
      Color borderColor = Colors.grey.shade400;

      // Add correct/incorrect styling here based on state.isChecked if desired
      if (state.isChecked && isInDropZone) {
        final isCorrect = isItemCorrect(index);
        if (isCorrect == true) {
          borderColor = Colors.green;
          bgColor = Colors.green.shade50;
        } else if (isCorrect == false) {
          borderColor = Colors.red;
          bgColor = Colors.red.shade50;
        }
      } else {
        borderColor = Theme.of(context).primaryColor;
      }

      return Material(
        elevation: isDragging ? 4 : 1,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(itemText),
        ),
      );
    }

    if (state.isChecked) {
      // If checked, just display the item, don't make it draggable
      return itemCard(false);
    }

    return Draggable<int>(
      data: index,
      feedback: itemCard(true), // What's shown under finger while dragging
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: itemCard(false),
      ), // What's left behind
      child: itemCard(false), // Default view
    );
  }
}
