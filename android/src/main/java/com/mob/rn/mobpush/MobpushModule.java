// MobpushModule.java

package com.mob.rn.mobpush;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.mob.MobSDK;
import com.mob.pushsdk.MobPush;
import com.mob.pushsdk.MobPushCallback;
import com.mob.pushsdk.MobPushCustomMessage;
import com.mob.pushsdk.MobPushNotifyMessage;
import com.mob.pushsdk.MobPushReceiver;
import com.mob.rn.mobpush.impl.CollectionUtils;
import com.mob.rn.mobpush.impl.MobPushLogger;
import com.mob.rn.mobpush.impl.ObjectUtils;
import com.mob.tools.utils.Hashon;
import com.mob.tools.utils.UIHandler;

public class MobpushModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private final Hashon hashon;
    public static final int MSG_UI = (int) System.currentTimeMillis();

    public MobpushModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        hashon = new Hashon();
        MobSDK.init(reactContext);
    }

    @Override
    public String getName() {
        return "MobPushModule";
    }

    /**
     * 隐私协议接口
     *
     * @param agree
     */
    @ReactMethod
    public void submitPolicyGrantResult(boolean agree) {
        MobPushLogger.getInstance().d("submitPolicyGrantResult agree=" + agree);
        MobSDK.submitPolicyGrantResult(agree, null);
    }

    /**
     * 获取rid
     *
     * @param callback
     */
    @ReactMethod
    public void getRegistrationID(final Callback callback) {
        MobPushLogger.getInstance().d("call getRegistrationID");
        MobPush.getRegistrationId(new MobPushCallback<String>() {
            @TargetApi(Build.VERSION_CODES.CUPCAKE)
            @Override
            public void onCallback(final String s) {
                final WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                map.putString("res", s);
                map.putString("error", null);
                if (!TextUtils.isEmpty(s) && ObjectUtils.nonNull(callback)) {
                    UIHandler.sendEmptyMessage(MSG_UI, new Handler.Callback() {
                        @Override
                        public boolean handleMessage(Message msg) {
                            callback.invoke(map);
                            return false;
                        }
                    });
                }
            }
        });
    }

    /**
     * 通知回调
     */
    @ReactMethod
    public void addListener(final String eventName) {
        MobPushLogger.getInstance().d("addListener");
        MobPush.addPushReceiver(new MobPushReceiver() {
            @Override
            public void onCustomMessageReceive(Context context, MobPushCustomMessage mobPushCustomMessage) {
                MobPushLogger.getInstance().d("onCustomMessageReceive");
                String customMessage = hashon.fromObject(mobPushCustomMessage);
                final WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                map.putString("res", customMessage);
                map.putString("error", null);
                sendEvent(reactContext, eventName, map);
            }

            @Override
            public void onNotifyMessageReceive(Context context, MobPushNotifyMessage mobPushNotifyMessage) {
                MobPushLogger.getInstance().d("onNotifyMessageReceive");
                String notifyMessage = hashon.fromObject(mobPushNotifyMessage);
                final WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                map.putString("res", notifyMessage);
                map.putString("error", null);
                sendEvent(reactContext, eventName, map);
            }

            @Override
            public void onNotifyMessageOpenedReceive(Context context, MobPushNotifyMessage mobPushNotifyMessage) {
                MobPushLogger.getInstance().d("onNotifyMessageOpenedReceive");
                String notifyMessage = hashon.fromObject(mobPushNotifyMessage);
                final WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                map.putString("res", notifyMessage);
                map.putString("error", null);
                sendEvent(reactContext, eventName, map);
            }

            @Override
            public void onTagsCallback(Context context, String[] tags, int operation, int errorCode) {
                MobPushLogger.getInstance().d("onTagsCallback");
                WritableMap params = Arguments.createMap();
                WritableArray tagArray = Arguments.createArray();
                if (ObjectUtils.nonNull(tags)) {
                    for (String tag : tags) {
                        tagArray.pushString(tag);
                    }
                }
                if (errorCode == 0) {
                    params.putBoolean("success", true);
                } else {
                    params.putBoolean("success", false);
                }
                params.putArray("res", tagArray);
                params.putInt("operation", operation);
                params.putInt("error", errorCode);
                sendEvent(reactContext, eventName, params);
            }

            @Override
            public void onAliasCallback(Context context, String alias, int operation, int errorCode) {
                MobPushLogger.getInstance().d("onAliasCallback");
                WritableMap params = Arguments.createMap();
                if (errorCode == 0) {
                    params.putBoolean("success", true);
                } else {
                    params.putBoolean("success", false);
                }
                params.putString("alias", alias);
                params.putInt("operation", operation);
                params.putInt("errorCode", errorCode);
                sendEvent(reactContext, eventName, params);
            }
        });
    }

    @ReactMethod
    public void removeListeners(Integer count) {
        //不做处理
    }

    /**
     * 停止推送
     */
    @ReactMethod
    public void stopPush() {
        MobPushLogger.getInstance().d("stopPush");
        MobPush.stopPush();
    }

    /**
     * 开启推送
     */
    @ReactMethod
    public void restartPush() {
        MobPushLogger.getInstance().d("restartPush");
        MobPush.restartPush();
    }

    /**
     * 判断通知是否开启
     *
     * @param callback 回调通知开启状态
     */
    @ReactMethod
    public void isPushStopped(final Callback callback) {
        MobPushLogger.getInstance().d("isPushStopped");
        MobPush.isPushStopped(new MobPushCallback<Boolean>() {
            @Override
            public void onCallback(Boolean aBoolean) {
                final WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                map.putBoolean("res", aBoolean);
                map.putString("error", null);
                if (ObjectUtils.nonNull(callback)) {
                    callback.invoke(map);
                }
            }
        });
    }

    @ReactMethod
    public void setAlias(String alias) {
        MobPushLogger.getInstance().d("setAlias");
        MobPush.setAlias(alias);
    }

    @ReactMethod
    public void getAlias() {
        MobPushLogger.getInstance().d("getAlias");
        MobPush.getAlias();
    }

    @ReactMethod
    public void deleteAlias() {
        MobPushLogger.getInstance().d("deleteAlias");
        MobPush.deleteAlias();
    }

    @ReactMethod
    public void addTags(ReadableMap array) {
        MobPushLogger.getInstance().d("addTags");
        ReadableArray arrayArray = array.getArray("tags");
        String[] tags = new String[arrayArray.size()];
        if (CollectionUtils.isEmpty(arrayArray)) {
            return;
        }
        for (int i = 0; i < arrayArray.size(); i++) {
            tags[i] = arrayArray.getString(i);
        }
        MobPush.addTags(tags);
    }

    @ReactMethod
    public void getAllTags() {
        MobPushLogger.getInstance().d("getTags");
        MobPush.getTags();
    }

    @ReactMethod
    public void deleteTags(ReadableMap map) {
        MobPushLogger.getInstance().d("deleteTags");
        ReadableArray arrayArray = map.getArray("tags");
        String[] tags = new String[arrayArray.size()];
        if (CollectionUtils.isEmpty(arrayArray)) {
            return;
        }
        for (int i = 0; i < arrayArray.size(); i++) {
            tags[i] = arrayArray.getString(i);
        }
        MobPush.deleteTags(tags);
    }

    @ReactMethod
    public void cleanAllTags() {
        MobPushLogger.getInstance().d("cleanAllTags");
        MobPush.cleanTags();
    }

    @ReactMethod
    public void setShowBadge(final boolean badgeCount) {
        MobPushLogger.getInstance().d("setShowBadge");
        MobPush.setShowBadge(badgeCount);
    }

    @ReactMethod
    public void getShowBadge(final Callback callback) {
        MobPushLogger.getInstance().d("getShowBadge");
        if (ObjectUtils.nonNull(callback)) {
            final WritableMap map = Arguments.createMap();
            boolean showBadge = MobPush.getShowBadge();
            map.putBoolean("success", true);
            map.putBoolean("res", showBadge);
            map.putString("error", null);
            callback.invoke(map);
        }
    }

    @ReactMethod
    public void setSilenceTime(int startHour, int startMinute, int endHour, int endMinute) {
        MobPushLogger.getInstance().d("setSilenceTime");
        MobPush.setSilenceTime(startHour, startMinute, endHour, endMinute);
    }

    @ReactMethod
    public void showToast(String msg, int type) {
        Toast.makeText(reactContext, msg, type == 0 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG).show();
    }


    private void sendEvent(ReactContext reactContext, String eventName, WritableMap params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }

}
