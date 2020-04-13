class MessageModel {
  final String fromId;
  final String toId;
  final int timeStamp;
  final String message;
  MessageModel(this.timeStamp, this.message, this.toId, this.fromId);
}