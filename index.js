
import {
    NativeEventEmitter,
    NativeModules,
    Platform
} from 'react-native'

const MobPushModule = NativeModules.MobPushModule;

const listeners = {}
const onTagsCallback = 'onTagsCallback'
const onAliasCallback = 'onAliasCallback'
const onLocalMessageReceive = 'onLocalMessageReceive'
const onCustomMessageReceive = 'onCustomMessageReceive'
const onNotifyMessageReceive = 'onNotifyMessageReceive'
const onNotifyMessageOpenedReceive = 'onNotifyMessageOpenedReceive'

export default class MobPush {
    /**
     * 手动注册App到SDK
     * @param {String} appKey 
     * @param {String} appSecret 
     */
    static initSDK(appKey, appSecret) {
        if (Platform.OS == 'ios') {
            MobPushModule.registerAppKey(appKey, appSecret);
        }
    }

    /*
    * 上传隐私协议状态
    * @params grant = BOOL
    * */
    static submitPolicyGrantResult(grant) {
        MobPushModule.submitPolicyGrantResult(grant);
    }

    static setDebugLog(enable) {
        if (Platform.OS == 'ios') {
            MobPushModule.setDebugLog(enable);
        }
    }

    /**
     * 配置消息推送类型
     * MPushAuthorizationOptionsNone、
     * MPushAuthorizationOptionsBadge、
     * MPushAuthorizationOptionsSound、
     * MPushAuthorizationOptionsAlert
     * @param {Int} types = MPushAuthorizationOptions
     */
    static setupNotification(types) {
        if (Platform.OS == 'ios') {
            MobPushModule.setupNotification(types);
        }
    }

    /**
     * 配置消息前台推送类型
     * MPushAuthorizationOptionsNone、
     * MPushAuthorizationOptionsBadge、
     * MPushAuthorizationOptionsSound、
     * MPushAuthorizationOptionsAlert
     * @param {Int} type = MPushAuthorizationOptions
     */
    static setAPNsShowForegroundType(type) {
        if (Platform.OS == 'ios') {
            MobPushModule.setAPNsShowForegroundType(type);
        }
    }

    /**
     * 发送消息
     * @param {Hash} params 
     * @param {Function} callback = (result) => {"success":bool,"res":workId,"error":err}
     */
    static sendMessage(params, callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.send(params, callback);
        }
    }

    /**
     * 发送本地消息
     * @param {Hash} params 
     * @param {Function} callback = (result) => {"success":bool,"res":null,"error":err}
     */
    static addLocalNotification(params, callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.addLocalNotification(params, callback);
        }
    }

    /**
     * 获取RegistrationID
     * @param {Function} callback = (result) => {"success":bool,"res":regID，"error":err}
     */
    static getRegistrationID(callback) {
        MobPushModule.getRegistrationID(callback);
    }

    /**
     * 推送服务是否关闭
     * @param {Function} callback = (result) => {"success":bool,"res":isStopeed，"error":err}
     */
    static isPushStopped(callback) {
        MobPushModule.isPushStopped(callback);
    }

    /**
     * 关闭推送服务
     */
    static stopPush() {
        MobPushModule.stopPush();
    }

    /**
     * 开启推送服务
     */
    static restartPush() {
        MobPushModule.restartPush();
    }

    /**
     * SDK版本号
     * @param {Function} callback = (result) => {"success":bool,"res":sdkVersion,"error":err}
     */
    static sdkVersion(callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.sdkVersion(callback);
        }
    }

    /**
     * 设置区域ID
     * @param {Number} regionID 0 国内，1 国外
     */
    static setRegionID(regionID) {
        if (Platform.OS == 'ios') {
            MobPushModule.setRegionID(regionID);
        }
    }

    /**
     * 设置SDK环境
     * @param {bool} isPro 
     */
    static setAPNsForProduction(isPro) {
        if (Platform.OS == 'ios') {
            MobPushModule.setAPNsForProduction(isPro);
        }
    }

    /**
     * 绑定手机号
     * @param {String} phone 
     * @param {Function} callback = (result) => {"success":bool,"res":phone,"error":err}
     */
    static bindPhoneNum(phone, callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.bindPhoneNum(phone, callback);
        }
    }

    /**
     * 获取绑定的手机号
     * @param {Function} callback = (result) => {"success":bool,"res":phone,"error":err}
     */
    static getPhoneNum(callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.getPhoneNum(callback);
        }
    }

    /**
     * 设置角标到服务器
     * 本地先调用setApplicationIconBadgeNumber函数来显示角标
     * 再将该角标值同步到Mob服务器
     * @param {Number} count 
     */
    static setShowBadgeCount(count) {
        if (Platform.OS == 'ios') {
            MobPushModule.setShowBadgeCount(count);
        }
    }

    /**
     * 获取服务器角标
     * @param {Function} callback 
     */
    static getShowBadgeCount(callback) {
        if (Platform.OS == 'ios') {
            MobPushModule.getShowBadge(callback);
        }
    }

    /**
     * 清除角标，但不清空通知栏消息
     */
    static clearBadge() {
        if (Platform.OS == 'ios') {
            MobPushModule.clearBadge();
        }
    }

    /*
    * 查询所有别名
    * */
    static getAlias() {
        MobPushModule.getAlias();
    }

    /*
    * 新增别名
    * @param alias = String
    * */
    static setAlias(alias) {
        MobPushModule.setAlias(alias);
    }

    /*
    * 删除别名
    * */
    static deleteAlias() {
        MobPushModule.deleteAlias();
    }

    /*
    * 新增标签
    *
    * 这个接口是增加逻辑，而不是覆盖逻辑
    *
    * @param params = {"tags": [String]}
    * */
    static addTags(params) {
        MobPushModule.addTags(params);
    }

    /*
    * 覆盖标签
    *
    * 需要理解的是，这个接口是覆盖逻辑，而不是增量逻辑。即新的调用会覆盖之前的设置
    *
    * @param tags = String Array
    * */
    static updateTags(tags) {
        if (Platform.OS == 'ios') {
            MobPushModule.replaceTags(params);
        }
    }

    /*
    * 删除指定标签
    *
    * @param tags = String Array
    * */
    static deleteTags(params) {
        MobPushModule.deleteTags(params);
    }

    /*
    * 清除所有标签
    * */
    static cleanAllTags() {
        MobPushModule.cleanAllTags();
    }

    /*
    * 查询所有标签
    * */
    static getAllTags() {
        MobPushModule.getAllTags();
    }

    /*
    * tag事件监听
    *
    * @param {Function} callback = (result) => {"success":bool,"res":any，"error":err}
    *
    * success:结果，true为操作成功
    * 
    * res: 输入的参数, tags or null
    * */
    static addTagsListener(callback) {
        const emitter = new NativeEventEmitter(MobPushModule);
        listeners[callback] = emitter.addListener(onTagsCallback, result => {
                callback(result)
            }
        )
    }

    /*
    * alias事件监听
    *
    * @param {Function} callback = (result) => {"success":bool,"res":any，"error":err}
    *
    * success:结果，true为操作成功
    * 
    * res: 输入的参数, alias or null
    * */
    static addAliasListener(callback) {
        const emitter = new NativeEventEmitter(MobPushModule);
        listeners[callback] = emitter.addListener(onAliasCallback, result => {
                callback(result)
            }
        )
    }

    /*
    * 消息事件监听
    *
    * @param {Function} callback = (result) => {"success":bool,"res":String，"error":err}
    *
    * success:结果，true为操作成功
    * 
    * res: 消息结构体 JSON字符串
    * */
    static addNotficationListener(callback) {
        const emitter = new NativeEventEmitter(MobPushModule);
        const customSubscription = emitter.addListener(onCustomMessageReceive, result => {
                callback(result)
            }
        )

        const apnsSubscription = emitter.addListener(onNotifyMessageReceive, result => {
                callback(result)
            }
        )

        const localSubscription = emitter.addListener(onLocalMessageReceive, result => {
                callback(result)
            }
        )

        const clickedSubscription = emitter.addListener(onNotifyMessageOpenedReceive, result => {
                callback(result)
            }
        )
        listeners[callback] = [
            customSubscription, 
            apnsSubscription, 
            localSubscription, 
            clickedSubscription
        ];
    }

    /**
     * 移除监听事件
     * @param {Function} callback 
     * @returns 
     */
    static removeListener(callback) {
        if (!listeners[callback]) {
            return
        }

        if (listeners[callback] instanceof Array) {
            listeners[callback].forEach((sub) => sub.remove());
        } else {
            listeners[callback].remove();
        }

        listeners[callback] = null
    }


    static setShowBadge(showbadge) {
    if (Platform.OS == 'android') {
        MobPushModule.setShowBadge(showbadge);
        }
    }

    static getShowBadge(callback) {
    if (Platform.OS == 'android') {
          MobPushModule.getShowBadge(callback);
         }
    }
}
