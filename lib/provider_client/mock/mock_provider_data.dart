class V2ETPlanMock {
  const V2ETPlanMock({
    required this.name,
    required this.badge,
    required this.price,
    required this.period,
    required this.traffic,
    required this.speed,
    required this.devices,
    required this.type,
    required this.notes,
  });

  final String name;
  final String badge;
  final String price;
  final String period;
  final String traffic;
  final String speed;
  final String devices;
  final String type;
  final List<String> notes;
}

class V2ETProxyGroupMock {
  const V2ETProxyGroupMock({required this.icon, required this.title, required this.subtitle, required this.active});
  final String icon;
  final String title;
  final String subtitle;
  final bool active;
}

class V2ETNodeMock {
  const V2ETNodeMock({required this.flag, required this.name, required this.subtitle, required this.delay, required this.active});
  final String flag;
  final String name;
  final String subtitle;
  final String delay;
  final bool active;
}

class V2ETConnectionMock {
  const V2ETConnectionMock({required this.host, required this.time, required this.chain, required this.up, required this.down});
  final String host;
  final String time;
  final List<String> chain;
  final String up;
  final String down;
}

const mockEmail = '11361808@163.com';
const mockPlanName = '月度套餐 🏅';
const mockInviteCode = 'L6C9jvcG';

const mockPlans = [
  V2ETPlanMock(
    name: '月度套餐',
    badge: '🏅',
    price: '¥20',
    period: '/月',
    traffic: '100GB',
    speed: '1000 Mbps',
    devices: '2台',
    type: '常规套餐',
    notes: ['100GB/月可选季付、半年付', '2 台客户端同时在线', '高速访问，全球节点分布', '支持 Win、Mac、iOS、安卓', '不提供专属远程服务'],
  ),
  V2ETPlanMock(
    name: '年度套餐',
    badge: '👑',
    price: '¥179',
    period: '/年',
    traffic: '200GB',
    speed: '1000 Mbps',
    devices: '3台',
    type: '常规套餐',
    notes: ['每月/200GB流量（限时活动）', '3台客户端同时在线', '高速访问，全球节点分布', '支持 Win、Mac、iOS、安卓', '可提供远程安装服务'],
  ),
  V2ETPlanMock(
    name: '尝鲜套餐',
    badge: '🏅',
    price: '¥15',
    period: '/一次性',
    traffic: '15GB',
    speed: '500 Mbps',
    devices: '2台',
    type: '一次性套餐',
    notes: ['15GB 一次性流量', '2 台客户端同时在线', '适合短期体验', '支持主流设备'],
  ),
];

const mockGroups = [
  V2ETProxyGroupMock(icon: '⭐', title: '主策略  v2et', subtitle: '自动选择', active: true),
  V2ETProxyGroupMock(icon: '⚡', title: '自动选择', subtitle: '日本-ChatGPT 专线', active: false),
  V2ETProxyGroupMock(icon: '↔', title: '故障转移', subtitle: '应急用这条!平时别用！频繁更新', active: false),
];

const mockNodes = [
  V2ETNodeMock(flag: '🇯🇵', name: '自动选择', subtitle: '日本-ChatGPT 专线', delay: '84ms', active: true),
  V2ETNodeMock(flag: '🌐', name: '故障转移', subtitle: '应急用这条!平时别用！频繁更新', delay: '299ms', active: false),
  V2ETNodeMock(flag: '🌐', name: '应急用这条!平时别用！频繁更新', subtitle: '', delay: '299ms', active: false),
  V2ETNodeMock(flag: '🌐', name: '应急2号线', subtitle: '', delay: '105ms', active: false),
  V2ETNodeMock(flag: '🇭🇰', name: '香港3', subtitle: '', delay: '314ms', active: false),
  V2ETNodeMock(flag: '🇭🇰', name: '香港1-GPT', subtitle: '', delay: '102ms', active: false),
  V2ETNodeMock(flag: '🇭🇰', name: '香港2-Claude', subtitle: '', delay: '310ms', active: false),
  V2ETNodeMock(flag: '🇭🇰', name: '香港3-Gemini', subtitle: '', delay: '102ms', active: false),
  V2ETNodeMock(flag: '🇭🇰', name: '香港3-转发', subtitle: '', delay: '139ms', active: false),
];

const mockConnections = [
  V2ETConnectionMock(host: '149.154.175.54:443', time: '刚刚', chain: ['香港3-Gemini', '自动选择', 'v2et'], up: '201 B · 0 B/s', down: '89 B · 0 B/s'),
  V2ETConnectionMock(host: '91.108.56.158:443', time: '刚刚', chain: ['香港3-Gemini', '自动选择', 'v2et'], up: '313 B · 0 B/s', down: '16.3 KB · 0 B/s'),
  V2ETConnectionMock(host: '149.154.175.55:443', time: '刚刚', chain: ['香港3-Gemini', '自动选择', 'v2et'], up: '201 B · 0 B/s', down: '89 B · 0 B/s'),
  V2ETConnectionMock(host: 'servicewechat.com/101.89.47.221:443', time: '9 分钟前', chain: ['DIRECT'], up: '2.5 KB · 0 B/s', down: '6.0 KB · 0 B/s'),
  V2ETConnectionMock(host: 'ipv4.gdt.qq.com:443', time: '9 分钟前', chain: ['DIRECT'], up: '9.4 KB · 0 B/s', down: '3.7 KB · 0 B/s'),
];
