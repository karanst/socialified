import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/live_imports.dart';

import '../../components/user_card.dart';

class LiveJoinedUsers extends StatefulWidget {
  const LiveJoinedUsers({Key? key}) : super(key: key);

  @override
  State<LiveJoinedUsers> createState() => _LiveJoinedUsersState();
}

class _LiveJoinedUsersState extends State<LiveJoinedUsers> {
  final AgoraLiveController agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Heading6Text(
          LocalizationString.joinedUsers,
            weight: TextWeight.bold
        ),
        const SizedBox(
          height: 20,
        ),
        divider(context: context),
        Expanded(
          child: GetBuilder<AgoraLiveController>(
              init: agoraLiveController,
              builder: (ctx) {
                return ListView.separated(
                    padding: const EdgeInsets.only(top: 20),
                    itemBuilder: (ctx, index) {
                      return UserTile(
                          profile: agoraLiveController.currentJoinedUsers[index]);
                    },
                    separatorBuilder: (ctx, index) {
                      return const SizedBox(
                        height: 20,
                      );
                    },
                    itemCount: agoraLiveController.currentJoinedUsers.length);
              }),
        ),
      ],
    ).hP16;
  }
}
