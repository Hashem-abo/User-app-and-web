import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';

class SourceSelectorTab extends StatelessWidget {
  final String selectedSource;
  final Function(String) onSourceChanged;

  const SourceSelectorTab({
    super.key,
    required this.selectedSource,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sources = [
      {'key': 'shein', 'label': 'Shein', 'emoji': '👗'},
      {'key': 'aliexpress', 'label': 'AliExpress', 'emoji': '🛒'},
      {'key': 'cj', 'label': 'CJ Drop', 'emoji': '📦'},
    ];

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: sources.map((source) {
          bool isSelected = selectedSource == source['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onSourceChanged(source['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(source['emoji']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        source['label']!,
                        style: TextStyle(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
