import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants/color_constants.dart';
import 'constants/size_constants.dart';

Widget errorContainer() {
  return const Icon(Icons.account_circle_rounded);
}

Widget chatImage({required String imageSrc, required Function onTap}) {
  return OutlinedButton(
    onPressed: onTap(),
    child: Image.network(
      imageSrc,
      width: 45,
      height: 45,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor2,
            borderRadius: BorderRadius.circular(Sizes.dimen_10),
          ),
          width: Sizes.dimen_200,
          height: Sizes.dimen_200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.burgundy,
              value: loadingProgress.expectedTotalBytes != null &&
                      loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}

Widget senderMessageBubble({
  required String chatContent,
  required readStatus,
  required timestamp,
  Color? color,
  Color? textColor,
}) {
  return Container(
    padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 5),
    width: Sizes.dimen_200,
    decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16))),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              chatContent,
              style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          // width: 80,
          child: Row(
            children: [
              Text(
                DateFormat('hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.black38,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 2),
              readStatus
                  ? const Icon(Icons.done_all_outlined,
                      color: Colors.black38, size: 18)
                  : const Icon(Icons.done_all_outlined,
                      color: Colors.white70, size: 18)
            ],
          ),
        )
      ],
    ),
  );
}

Widget recieverMessageBubble({
  required String chatContent,
  required readStatus,
  required timestamp,
  Color? color,
  Color? textColor,
}) {
  return Container(
    padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 5),
    width: Sizes.dimen_200,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              chatContent,
              style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          // width: 80,
          child: Row(
            children: [
              Text(
                DateFormat('hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
              // const SizedBox(width: 2),
            ],
          ),
        )
      ],
    ),
  );
}
