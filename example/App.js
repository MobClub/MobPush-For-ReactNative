import React, { Component } from 'react';
import { Button, Platform, StyleSheet, Text, View } from 'react-native';
import { NativeEventEmitter, NativeModules } from 'react-native';
import MobPush from 'react-native-mobpush';
const MobPushModule = NativeModules.MobPushModule;

export default class App extends Component<{}> {
  componentDidMount() {
    //同意隐私协议
    MobPush.submitPolicyGrantResult(true);
    // 开启iOS端Debug日志
    MobPush.setDebugLog(true);
    if (Platform.OS == 'ios') {
      MobPush.setRegionID(0);
      MobPush.setAPNsForProduction(true);
      MobPush.setupNotification(MobPushModule.MPushAuthorizationOptionsBadge | MobPushModule.MPushAuthorizationOptionsAlert | MobPushModule.MPushAuthorizationOptionsSound);
    }
  }
  /**获取推送rid */
  getRegistrationID() {
    MobPush.getRegistrationID(function(map) {
      if(map.success){
        if (map.res) {
          console.log("rid=" + map.res);
        }
      } else{
        if (map.error) {
          console.log("error=" + map.error);
        }
      }
    });
  }
  /**
   * 通知回调
   */
  addPushReceiver() {
    this.notificationListener = (result) => {
      console.log(result);
    };
    MobPush.addNotficationListener(this.notificationListener);

    this.tagsListener = (result) => {
      console.log(result);
    };
    MobPush.addTagsListener(this.tagsListener);

    this.aliasListener = (result) => {
      console.log(result);
    };
    MobPush.addAliasListener(this.aliasListener);
  }
  /**停止推送 */
  stopPush() {
    MobPush.stopPush();
  }
  /**恢复推送 */
  restartPush() {
    MobPush.restartPush();
  }

  isPushStopped() {
    MobPush.isPushStopped(function(result) {
      if(result.success){
        console.log("推送是否关闭:" + result.res);
      } else{
        if (result.error) {
          console.log("error=" + result.error);
        }
      }
    })
  }
  /**设置别名 */
  setAlias() {
    MobPush.setAlias('aa')
  }
  /**获取别名 */
  getAlias() {
    MobPush.getAlias();
  }
  /**删除别名 */
  deleteAlias() {
    MobPush.deleteAlias();
  }
  /**增加标签
   * @param tags 数组
   */
  addTags() {
    var tagsArray = {"tags": ["tag1", "tag2", "tag3"]};
    MobPush.addTags(tagsArray);
  }
  /**获取标签 */
  getTags() {
    MobPush.getAllTags();
  }
  /**删除标签 */
  deleteTags() {
    var tagsArray = {"tags": ["tag1"]}
    MobPush.deleteTags(tagsArray)
  }
  /**清除标签 */
  cleanAllTags() {
    MobPush.cleanAllTags();
  }
  /**是否显示角标 */
  setShowBadge() {
    if (Platform.OS == 'android') {
      MobPush.setShowBadge(true);
    }
  }

  getShowBadge() {
    if (Platform.OS == 'android') {
      MobPush.getShowBadge(function(map) {
        if(map.success){
          console.log("是否显示角标:" + map.res);
        } else{
          console.log("error=" + map.error);
        }
      })
    } else {
      MobPush.getShowBadgeCount((result) => {
        if (result.success && result.res) {
          console.log("服务端角标数: ", result.res);
        }
      })
    }
  }

  /**设置静默时间，不展示通知 */
  setSilenceTime(startHour, startMinute, endHour, endMinute) {
    if (Platform.OS == 'android') {
      MobPush.setSilenceTime(startHour, startMinute, endHour, endMinute);
    }
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>☆Mobpush example☆</Text>
        <Text style={styles.buttonStyle} onPress={this.getRegistrationID}>获取rid</Text>
        <Text style={styles.buttonStyle} onPress={this.addPushReceiver}>设置推送回调</Text>
        <Text style={styles.buttonStyle} onPress={this.stopPush}  >关闭推送</Text>
        <Text style={styles.buttonStyle} onPress={this.restartPush} >恢复推送</Text>
        <Text style={styles.buttonStyle} onPress={this.isPushStopped}  >获取推送是否关闭</Text>
        <Text style={styles.buttonStyle} onPress={this.setAlias} >设置别名</Text>
        <Text style={styles.buttonStyle} onPress={this.getAlias} >获取别名</Text>
        <Text style={styles.buttonStyle} onPress={this.deleteAlias}  >删除别名</Text>
        <Text style={styles.buttonStyle} onPress={this.addTags} >添加标签</Text>
        <Text style={styles.buttonStyle} onPress={this.getTags} >获取标签</Text>
        <Text style={styles.buttonStyle} onPress={this.deleteTags} >删除标签</Text>
        <Text style={styles.buttonStyle} onPress={this.cleanAllTags} >清除标签</Text>
        <Text style={styles.buttonStyle} onPress={this.setShowBadge} >设置是否展示角标</Text>
        <Text style={styles.buttonStyle} onPress={this.getShowBadge} >获取是否展示角标</Text>
        {/* <Button onPress={this.setSilenceTime} title="设置静默时间" /> */}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  buttonStyle: {
    marginTop: 5,
    height: 40,
    width: 150,
    textAlign: 'center',
    textAlignVertical: 'center',
    marginHorizontal: 10,
    backgroundColor: '#E6E6FA'
  },
  container: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
