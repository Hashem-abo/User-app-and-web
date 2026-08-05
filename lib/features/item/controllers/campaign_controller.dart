import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/services/campaign_service_interface.dart';

class CampaignController extends GetxController implements GetxService {
  final CampaignServiceInterface campaignServiceInterface;
  CampaignController({required this.campaignServiceInterface});

  List<BasicCampaignModel>? _basicCampaignList;
  List<BasicCampaignModel>? get basicCampaignList => _basicCampaignList;

  BasicCampaignModel? _basicCampaign;
  BasicCampaignModel? get basicCampaign => _basicCampaign;

  List<Item>? _itemCampaignList;
  List<Item>? get itemCampaignList => _itemCampaignList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final Map<int, List<BasicCampaignModel>> _moduleBasicCampaignList = {};
  final Map<int, List<Item>> _moduleItemCampaignList = {};

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void itemAndBasicCampaignNull(){
    _itemCampaignList = null;
    _basicCampaignList = null;
  }

  Future<void> getBasicCampaignList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && currentModuleId != null && _moduleBasicCampaignList.containsKey(currentModuleId)) {
      _basicCampaignList = _moduleBasicCampaignList[currentModuleId];
      update();
      return;
    } else if (!reload && currentModuleId == null) {
      _basicCampaignList = null;
    }

    if(_basicCampaignList == null || reload || fromRecall) {
      if(reload) {
        _basicCampaignList = null;
      }
      List<BasicCampaignModel>? basicCampaignList;
      if(dataSource == DataSourceEnum.local) {
        basicCampaignList = await campaignServiceInterface.getBasicCampaignList(DataSourceEnum.local);
        _prepareBasicCampaign(basicCampaignList);
        if (currentModuleId != null && _basicCampaignList != null) {
          _moduleBasicCampaignList[currentModuleId] = _basicCampaignList!;
        }
        getBasicCampaignList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        basicCampaignList = await campaignServiceInterface.getBasicCampaignList(DataSourceEnum.client);
        _prepareBasicCampaign(basicCampaignList);
        if (currentModuleId != null && _basicCampaignList != null) {
          _moduleBasicCampaignList[currentModuleId] = _basicCampaignList!;
        }
      }

    }
  }

  void _prepareBasicCampaign(List<BasicCampaignModel>? basicCampaignList) {
    if (basicCampaignList != null) {
      _basicCampaignList = [];
      _basicCampaignList!.addAll(basicCampaignList);
    }
    update();
  }

  Future<void> getBasicCampaignDetails(int? campaignID) async {
    _basicCampaign = null;
    BasicCampaignModel? basicCampaign = await campaignServiceInterface.getCampaignDetails(campaignID.toString());
    if (basicCampaign != null) {
      _basicCampaign = basicCampaign;
    }
    update();
  }

  Future<void> getItemCampaignList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && currentModuleId != null && _moduleItemCampaignList.containsKey(currentModuleId)) {
      _itemCampaignList = _moduleItemCampaignList[currentModuleId];
      update();
      return;
    } else if (!reload && currentModuleId == null) {
      _itemCampaignList = null;
    }

    if(_itemCampaignList == null || reload || fromRecall) {
      if(reload) {
        _itemCampaignList = null;
      }
      List<Item>? itemCampaignList;
      if(dataSource == DataSourceEnum.local) {
        itemCampaignList = await campaignServiceInterface.getItemCampaignList(DataSourceEnum.local);
        _prepareItemCampaign(itemCampaignList);
        if (currentModuleId != null && _itemCampaignList != null) {
          _moduleItemCampaignList[currentModuleId] = _itemCampaignList!;
        }
        getItemCampaignList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        itemCampaignList = await campaignServiceInterface.getItemCampaignList(DataSourceEnum.client);
        _prepareItemCampaign(itemCampaignList);
        if (currentModuleId != null && _itemCampaignList != null) {
          _moduleItemCampaignList[currentModuleId] = _itemCampaignList!;
        }
      }

    }
  }

  void _prepareItemCampaign(List<Item>? itemCampaignList) {
    _itemCampaignList = [];
    if (itemCampaignList != null) {
      List<Item> campaign = [];
      campaign.addAll(itemCampaignList);
      for (var c in campaign) {
        if(!Get.find<SplashController>().getModuleConfig(c.moduleType).newVariation! || c.variations!.isEmpty || c.foodVariations!.isNotEmpty) {
          _itemCampaignList!.add(c);
        }
      }
    }
    update();
  }

  void setCampaignData({List<BasicCampaignModel>? basicCampaigns, List<Item>? itemCampaigns}) {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (basicCampaigns != null) {
      _prepareBasicCampaign(basicCampaigns);
      if (currentModuleId != null && _basicCampaignList != null) {
        _moduleBasicCampaignList[currentModuleId] = _basicCampaignList!;
      }
    }
    if (itemCampaigns != null) {
      _prepareItemCampaign(itemCampaigns);
      if (currentModuleId != null && _itemCampaignList != null) {
        _moduleItemCampaignList[currentModuleId] = _itemCampaignList!;
      }
    }
    update();
  }
}