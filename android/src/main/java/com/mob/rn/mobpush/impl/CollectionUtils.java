package com.mob.rn.mobpush.impl;

import com.facebook.react.bridge.ReadableArray;

import java.util.Collection;
import java.util.Map;

public class CollectionUtils {
	public static boolean isEmpty(Collection collection) {
		return collection == null || collection.isEmpty();
	}

	public static boolean isEmpty(Map map) {
		return map == null || map.isEmpty();
	}

	public static boolean isEmpty(Object[] objects) {
		return objects == null || objects.length == 0;
	}

	public static boolean isEmpty(ReadableArray array) {
		return array == null || array.size() == 0;
	}
}
