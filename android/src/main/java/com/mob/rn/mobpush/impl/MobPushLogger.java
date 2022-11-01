package com.mob.rn.mobpush.impl;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import com.mob.MobSDK;
import com.mob.pushsdk.base.PLog;

public class MobPushLogger {
	private static final String TAG = "MobPushLogger";
	private static MobPushLogger mobPushLogger;
	private static final String DEBUGMETA = "com.mob.mobpush.debugLevel";
	private static int debugLevel = 0;

	private MobPushLogger() {
		Context context = MobSDK.getContext();
		Bundle metaData = null;
		try {
			PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), PackageManager.GET_META_DATA);
			metaData = packageInfo.applicationInfo.metaData;
			if (metaData != null) {
				debugLevel = metaData.getInt(DEBUGMETA);
			}
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		} catch (Throwable throwable) {
			PLog.getInstance().e(throwable);
		}
	}

	public static MobPushLogger getInstance() {
		if (mobPushLogger == null) {
			synchronized (MobPushLogger.class) {
				if (mobPushLogger == null) {
					mobPushLogger = new MobPushLogger();
				}
			}
		}
		return mobPushLogger;
	}

	public void d(String info) {
		if (debugLevel >= 1) {
			Log.i(TAG, "[MobPush]" + info);
		}
	}

	public void i(String info) {
		if (debugLevel > 1) {
			Log.i(TAG, "[MobPush]" + info);
		}
	}

	public void w(String info) {
		if (debugLevel > 2) {
			Log.w(TAG, "[MobPush]" + info);
		}
	}

	public void e(String info) {
		if (debugLevel >= 4) {
			Log.e(TAG, "[MobPush]" + info);
		}
	}

	public void w(Throwable throwable) {
		try {
			if (debugLevel >= 4) {
				Log.e(TAG, "[MobPush]" + throwable.getMessage());
			}
		} catch (Exception e) {
		}
	}
}
