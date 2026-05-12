/// Metadata for each servo channel (display order is top → bottom in [kJointChannelsDisplayTopToBottom]).
class JointChannel {
  final int protocolIndex;
  final String title;
  final String servoId;
  final int arduinoPin;

  const JointChannel({
    required this.protocolIndex,
    required this.title,
    required this.servoId,
    required this.arduinoPin,
  });
}

/// Visual order: top of screen = Gripper; bottom = Base (matches reference bottom→top servo list).
const List<JointChannel> kJointChannelsDisplayTopToBottom = [
  JointChannel(
    protocolIndex: 6,
    title: 'Base Rotation',
    servoId: 'servo_5',
    arduinoPin: 9,
  ),
  JointChannel(
    protocolIndex: 5,
    title: 'Lower Arm / Shoulder',
    servoId: 'servo_4',
    arduinoPin: 8,
  ),
  JointChannel(
    protocolIndex: 4,
    title: 'Middle Joint / Elbow',
    servoId: 'servo_3',
    arduinoPin: 7,
  ),
  JointChannel(
    protocolIndex: 3,
    title: 'Upper Wrist Joint',
    servoId: 'servo_2',
    arduinoPin: 6,
  ),
  JointChannel(
    protocolIndex: 2,
    title: 'Wrist Rotation',
    servoId: 'servo_1',
    arduinoPin: 5,
  ),
  JointChannel(
    protocolIndex: 1,
    title: 'Gripper / Claw',
    servoId: 'servo_0',
    arduinoPin: 4,
  ),
];
/// Metadata for each servo channel (display order is top → bottom in [kJointChannelsDisplayTopToBottom]).
