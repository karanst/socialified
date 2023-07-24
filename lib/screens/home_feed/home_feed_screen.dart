import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/my_profile.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_polls/flutter_polls.dart';

import '../../components/post_card.dart';
import '../../controllers/add_post_controller.dart';
import '../../controllers/agora_live_controller.dart';
import '../../controllers/home_controller.dart';
import '../../model/call_model.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../dashboard/explore.dart';
import '../post/select_media.dart';
import '../post/view_post_insight.dart';
import '../settings_menu/settings_controller.dart';
import '../story/choose_media_for_story.dart';
import '../story/story_updates_bar.dart';
import '../story/story_viewer.dart';
import 'map_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SettingsController _settingsController = Get.find();

  final _controller = ScrollController();

  String? selectedValue;
  int pollFrequencyIndex = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(isRecent: true);

      _homeController.loadQuickLinksAccordingToSettings();
    });

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          loadData(isRecent: false);
        }
      }
    });
  }

  loadMore({required bool? isRecent}) {
    loadPosts(isRecent);
  }

  refreshData() {
    _homeController.clear();
    loadData(isRecent: false);
  }

  @override
  void dispose() {
    super.dispose();
    _homeController.clear();
    _homeController.closeQuickLinks();
  }

  loadPosts(bool? isRecent) {
    _homeController.getPosts(
        isRecent: isRecent,
        callback: () {
          _refreshController.refreshCompleted();
        });
  }

  void loadData({required bool? isRecent}) {
    loadPosts(isRecent);
    _homeController.getStories();
  }

  @override
  void didUpdateWidget(covariant HomeFeedScreen oldWidget) {
    loadData(isRecent: false);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        floatingActionButton: Container(
          height: 50,
          width: 50,
          color: AppColorConstants.themeColor,
          child: const ThemeIconWidget(
            ThemeIcon.edit,
            size: 25,
          ),
        ).circular.ripple(() {
          Future.delayed(
            Duration.zero,
            () => showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SelectMedia()),
          );
        }),
        appBar: AppBar(
          backgroundColor: AppColorConstants.backgroundColor,
          leading: Container(
              height: 60,
              width: 60,
              child: Image.asset('assets/applogo.jpeg')),
          title: Heading4Text(
            AppConfigConstants.appName,
            weight: TextWeight.regular,
            color: AppColorConstants.themeColor,
          ),
            actions: [
              const ThemeIconWidget(
                ThemeIcon.search,
                size: 25,
              ).ripple(() {
                Get.to(() => const Explore());
              }),

              const ThemeIconWidget(
                ThemeIcon.notification,
                size: 25,
              ).ripple(() {
             //   Get.to(() => const Explore());
              }),
              const ThemeIconWidget(
                ThemeIcon.name,
                size: 25,
              ).ripple(() {
                Get.to(() =>  const MyProfile(
                      showBack: true,
                ),);
              }),
              const SizedBox(width: 7,),
              Obx(() => Container(
                color: AppColorConstants.backgroundColor,
                height: 25,
                width: 25,
                child: ThemeIconWidget(
                  _homeController.openQuickLinks.value == true
                      ? ThemeIcon.close
                      : ThemeIcon.menuIcon,
                  // color: ColorConstants.themeColor,
                  size: 25,
                ),
              ).ripple(() {
                _homeController.quickLinkSwitchToggle();
              })),
              const SizedBox(width: 7,)
            ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // menuView(),

            // Row(
            //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //
            //
            //     const Spacer(),
            //     // const ThemeIconWidget(
            //     //   ThemeIcon.map,
            //     //   // color: ColorConstants.themeColor,
            //     //   size: 25,
            //     // ).ripple(() {
            //     //   Get.to(() => MapsUsersScreen());
            //     // }),
            //     // const SizedBox(
            //     //   width: 20,
            //     // ),
            //     const ThemeIconWidget(
            //       ThemeIcon.search,
            //       size: 25,
            //     ).ripple(() {
            //       Get.to(() => const Explore());
            //     }),
            //
            //     const ThemeIconWidget(
            //       ThemeIcon.notification,
            //       size: 25,
            //     ).ripple(() {
            //       Get.to(() => const Explore());
            //     }),
            //     const ThemeIconWidget(
            //       ThemeIcon.name,
            //       size: 25,
            //     ).ripple(() {
            //       Get.to(() => const Explore());
            //     }),
            //     const SizedBox(
            //       width: 20,
            //     ),
            //     Obx(() => Container(
            //           color: AppColorConstants.backgroundColor,
            //           height: 25,
            //           width: 25,
            //           child: ThemeIconWidget(
            //             _homeController.openQuickLinks.value == true
            //                 ? ThemeIcon.close
            //                 : ThemeIcon.menuIcon,
            //             // color: ColorConstants.themeColor,
            //             size: 25,
            //           ),
            //         ).ripple(() {
            //           _homeController.quickLinkSwitchToggle();
            //         })),
            //   ],
            // ).hp(20),
            // const SizedBox(
            //   height: 10,
            // ),
            Expanded(
              child: postsView(),
            ),
          ],
        ));
  }

  // Widget menuView() {
  //   return Obx(() => AnimatedContainer(
  //         height: _homeController.openQuickLinks.value == true ? 450 : 0,
  //         width: Get.width,
  //         color: ColorConstants.themeColor,
  //         duration: const Duration(milliseconds: 500),
  //         child: QuickLinkWidget(callback: () {
  //           _homeController.closeQuickLinks();
  //         }),
  //       ));
  // }

  Widget postingView() {
    return Obx(() => _addPostController.isPosting.value
        ? Container(
            height: 55,
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                Image.memory(
                  _addPostController.postingMedia.first.thumbnail!,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ).round(5),
                const SizedBox(
                  width: 10,
                ),
                Heading5Text(
                  _addPostController.isErrorInPosting.value
                      ? LocalizationString.postFailed
                      : LocalizationString.posting,
                ),
                const Spacer(),
                _addPostController.isErrorInPosting.value
                    ? Row(
                        children: [
                          Heading5Text(
                            LocalizationString.discard,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.discardFailedPost();
                          }),
                          const SizedBox(
                            width: 20,
                          ),
                          Heading5Text(
                            LocalizationString.retry,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.retryPublish(context);
                          }),
                        ],
                      )
                    : Container()
              ],
            ).hP8,
          ).backgroundCard(radius: 10).bp(20)
        : Container());
  }

  Widget storiesView() {
    return SizedBox(
      height: 110,
      child: GetBuilder<HomeController>(
          init: _homeController,
          builder: (ctx) {
            return StoryUpdatesBar(
              stories: _homeController.stories,
              liveUsers: _homeController.liveUsers,
              addStoryCallback: () {
                // Get.to(() => const TextStoryMaker());
                Get.to(() => const ChooseMediaForStory());
              },
              viewStoryCallback: (story) {
                Get.to(() => StoryViewer(
                      story: story,
                      storyDeleted: () {
                        _homeController.getStories();
                      },
                    ));
              },
              joinLiveUserCallback: (user) {
                Live live = Live(
                    channelName: user.liveCallDetail!.channelName,
                    isHosting: false,
                    host: user,
                    token: user.liveCallDetail!.token,
                    liveId: user.liveCallDetail!.id);
                _agoraLiveController.joinAsAudience(
                  live: live,
                );
              },
            ).vP16;
          }),
    );
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _homeController.posts.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() =>
                      _homeController.isRefreshingStories.value == true
                          ? const StoryAndHighlightsShimmer()
                          : storiesView());
                }
                // else if (index == 1) {
                //   return const QuickLinkWidget();
                // }
                else if (index == 1) {
                  return postingView().hP16;
                } else if (index == 2) {
                  return Obx(() => Column(
                        children: [
                          HorizontalMenuBar(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              onSegmentChange: (segment) {
                                _homeController.categoryIndexChanged(
                                    index: segment,
                                    callback: () {
                                      _refreshController.refreshCompleted();
                                    });
                              },
                              selectedIndex:
                                  _homeController.categoryIndex.value,
                              menus: [
                                LocalizationString.all,
                                LocalizationString.following,
                                // LocalizationString.trending,
                                LocalizationString.recent,
                                LocalizationString.your,
                              ]),
                          _homeController.isRefreshingPosts.value == true
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: const HomeScreenShimmer())
                              : _homeController.posts.isEmpty
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: emptyPost(
                                          title: LocalizationString.noPostFound,
                                          subTitle: LocalizationString
                                              .followFriendsToSeeUpdates),
                                    )
                                  : Container()
                        ],
                      ));
                } else {
                  PostModel model = _homeController.posts[index - 3];

                  return PostCard(
                    model: model,
                    textTapHandler: (text) {
                      _homeController.postTextTapHandler(
                          post: model, text: text);
                    },
                    viewInsightHandler: () {
                      Get.to(() => ViewPostInsights(post: model));
                    },
                    // mediaTapHandler: (post) {
                    //   // Get.to(()=> PostMediaFullScreen(post: post));
                    // },
                    removePostHandler: () {
                      _homeController.removePostFromList(model);
                    },
                    blockUserHandler: () {
                      _homeController.removeUsersAllPostFromList(model);
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 0,
                );
              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: false,
              onRefresh: refreshData,
              onLoading: () {});
    });
  }
}
