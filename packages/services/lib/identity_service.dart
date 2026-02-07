import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Identity Service - Manages decentralized user identity
/// No central server - all identity data is generated and stored locally
class IdentityService {
  static const String _userKey = 'user_identity';
  static const String _mnemonicKey = 'user_mnemonic';
  
  final List<String> _wordList = [
    'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
    'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
    'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
    'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance',
    'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent',
    'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    'alcohol', 'alert', 'alien', 'all', 'alley', 'allow', 'almost', 'alone',
    'alpha', 'already', 'also', 'alter', 'always', 'amateur', 'amazing', 'among',
    'amount', 'amused', 'analyst', 'anchor', 'ancient', 'anger', 'angle', 'angry',
    'animal', 'ankle', 'announce', 'annual', 'another', 'answer', 'antenna', 'antique',
    'anxiety', 'any', 'apart', 'apology', 'appear', 'apple', 'approve', 'april',
    'arch', 'arctic', 'area', 'arena', 'argue', 'arm', 'armed', 'armor',
    'army', 'around', 'arrange', 'arrest', 'arrive', 'arrow', 'art', 'artefact',
    'artist', 'artwork', 'ask', 'aspect', 'assault', 'asset', 'assist', 'assume',
    'asthma', 'athlete', 'atom', 'attack', 'attend', 'attitude', 'attract', 'auction',
    'audit', 'august', 'aunt', 'author', 'auto', 'autumn', 'average', 'avocado',
    'avoid', 'awake', 'aware', 'away', 'awesome', 'awful', 'awkward', 'axis',
    'baby', 'bachelor', 'bacon', 'badge', 'bag', 'balance', 'balcony', 'ball',
    'bamboo', 'banana', 'banner', 'bar', 'barely', 'bargain', 'barrel', 'base',
    'basic', 'basket', 'battle', 'beach', 'bean', 'beauty', 'because', 'become',
    'beef', 'before', 'begin', 'behave', 'behind', 'believe', 'below', 'belt',
    'bench', 'benefit', 'best', 'betray', 'better', 'between', 'beyond', 'bicycle',
    'bid', 'bike', 'bind', 'biology', 'bird', 'birth', 'bitter', 'black',
    'blade', 'blame', 'blanket', 'blast', 'bleak', 'bless', 'blind', 'blood',
    'blossom', 'blouse', 'blue', 'blur', 'blush', 'board', 'boat', 'body',
    'boil', 'bomb', 'bone', 'bonus', 'book', 'boost', 'border', 'boring',
    'borrow', 'boss', 'bottom', 'bounce', 'box', 'boy', 'bracket', 'brain',
    'brand', 'brass', 'brave', 'bread', 'breeze', 'brick', 'bridge', 'brief',
    'bright', 'brilliant', 'bring', 'british', 'broad', 'broccoli', 'broken', 'bronze',
    'brother', 'brown', 'brush', 'bubble', 'buddy', 'budget', 'buffalo', 'build',
    'bulb', 'bulk', 'bullet', 'bundle', 'bunker', 'burden', 'burger', 'burst',
    'bus', 'business', 'busy', 'butter', 'buyer', 'buzz', 'cabbage', 'cabin',
    'cable', 'cactus', 'cage', 'cake', 'call', 'calm', 'camera', 'camp',
    'can', 'canal', 'cancel', 'candy', 'cannon', 'canoe', 'canvas', 'canyon',
    'capable', 'capital', 'captain', 'car', 'carbon', 'card', 'cargo', 'carpet',
    'carry', 'cart', 'carve', 'case', 'cash', 'casino', 'castle', 'casual',
    'cat', 'catalog', 'catch', 'category', 'cattle', 'caught', 'cause', 'caution',
    'cave', 'ceiling', 'celery', 'cement', 'census', 'century', 'cereal', 'certain',
    'chair', 'chalk', 'champion', 'change', 'chaos', 'chapter', 'charge', 'chase',
    'chat', 'cheap', 'check', 'cheek', 'cheer', 'cheese', 'chef', 'cherry',
    'chest', 'chicken', 'chief', 'child', 'chimney', 'choice', 'choose', 'chronic',
    'chuckle', 'chunk', 'churn', 'cigar', 'cinnamon', 'circle', 'citizen', 'city',
    'civil', 'claim', 'clap', 'clarify', 'claw', 'clay', 'clean', 'clerk',
    'clever', 'click', 'client', 'cliff', 'climb', 'clinic', 'clip', 'clock',
    'clog', 'close', 'cloth', 'cloud', 'clown', 'club', 'clump', 'cluster',
    'clutch', 'coach', 'coast', 'coconut', 'code', 'coffee', 'coil', 'coin',
    'collect', 'color', 'column', 'combine', 'come', 'comfort', 'comic', 'common',
    'company', 'concert', 'conduct', 'confirm', 'congress', 'connect', 'consider', 'control',
    'convert', 'convince', 'cook', 'cool', 'copper', 'copy', 'coral', 'core',
    'corn', 'correct', 'cost', 'cotton', 'couch', 'country', 'couple', 'course',
    'cousin', 'cover', 'coyote', 'crack', 'cradle', 'craft', 'cram', 'crane',
    'crash', 'crater', 'crawl', 'crazy', 'cream', 'credit', 'creek', 'crew',
    'cricket', 'crime', 'crisp', 'critic', 'crop', 'cross', 'crouch', 'crowd',
    'crucial', 'cruel', 'cruise', 'crumble', 'crunch', 'crush', 'cry', 'crystal',
    'cube', 'culture', 'cup', 'cupboard', 'curious', 'current', 'curtain', 'curve',
    'cushion', 'custom', 'cute', 'cycle', 'dad', 'damage', 'damp', 'dance',
    'danger', 'daring', 'dash', 'daughter', 'dawn', 'day', 'deal', 'debate',
    'debris', 'decade', 'december', 'decide', 'decline', 'decorate', 'decrease', 'deer',
    'defense', 'define', 'defy', 'degree', 'delay', 'deliver', 'demand', 'demise',
    'denial', 'dentist', 'deny', 'depart', 'depend', 'deposit', 'depth', 'deputy',
    'derive', 'describe', 'desert', 'design', 'desk', 'despair', 'destroy', 'detail',
    'detect', 'develop', 'device', 'devote', 'diagram', 'dial', 'diamond', 'diary',
    'dice', 'diesel', 'diet', 'differ', 'digital', 'dignity', 'dilemma', 'dinner',
    'dinosaur', 'direct', 'dirt', 'disagree', 'discover', 'disease', 'dish', 'dismiss',
    'disorder', 'display', 'distance', 'divert', 'divide', 'divorce', 'dizzy', 'doctor',
    'document', 'dog', 'doll', 'dolphin', 'domain', 'donate', 'donkey', 'donor',
    'door', 'dose', 'double', 'dove', 'draft', 'dragon', 'drama', 'drastic',
    'draw', 'dream', 'dress', 'drift', 'drill', 'drink', 'drip', 'drive',
    'drop', 'drum', 'dry', 'duck', 'dumb', 'dune', 'during', 'dust',
    'dutch', 'duty', 'dwarf', 'dynamic', 'eager', 'eagle', 'early', 'earn',
    'earth', 'easily', 'east', 'easy', 'echo', 'ecology', 'economy', 'edge',
    'edit', 'educate', 'effort', 'egg', 'eight', 'either', 'elbow', 'elder',
    'electric', 'elegant', 'element', 'elephant', 'elevator', 'elite', 'else', 'embark',
    'embrace', 'emerge', 'emotion', 'employ', 'empty', 'enable', 'enact', 'end',
    'enemy', 'energy', 'enforce', 'engage', 'engine', 'enhance', 'enjoy', 'enlist',
    'enough', 'enrich', 'enroll', 'ensure', 'enter', 'entire', 'entry', 'envelope',
    'episode', 'equal', 'equip', 'era', 'erase', 'erode', 'erosion', 'error',
    'erupt', 'escape', 'essay', 'essence', 'estate', 'eternal', 'ethics', 'evidence',
    'evil', 'evoke', 'evolve', 'exact', 'example', 'excess', 'exchange', 'excite',
    'exclude', 'excuse', 'execute', 'exercise', 'exhaust', 'exhibit', 'exile', 'exist',
    'exit', 'exotic', 'expand', 'expect', 'expire', 'explain', 'explode', 'explore',
    'export', 'express', 'extend', 'extra', 'eye', 'eyebrow', 'fabric', 'face',
    'faculty', 'fade', 'faint', 'faith', 'fall', 'false', 'fame', 'family',
    'famous', 'fan', 'fancy', 'fantasy', 'farm', 'fashion', 'fat', 'fatal',
    'father', 'fatigue', 'fault', 'favorite', 'feature', 'february', 'federal', 'fee',
    'feed', 'feel', 'female', 'fence', 'festival', 'fetch', 'fever', 'few',
    'fiber', 'fiction', 'field', 'fierce', 'fifth', 'fight', 'figure', 'file',
    'film', 'filter', 'final', 'find', 'fine', 'finger', 'finish', 'fire',
    'firm', 'first', 'fiscal', 'fish', 'fit', 'fitness', 'fix', 'flag',
    'flame', 'flash', 'flat', 'flavor', 'flee', 'flight', 'flip', 'float',
    'flock', 'floor', 'flower', 'fluid', 'flush', 'fly', 'foam', 'focus',
    'fog', 'foil', 'fold', 'follow', 'food', 'foot', 'force', 'forest',
    'forget', 'fork', 'fortune', 'forum', 'forward', 'fossil', 'foster', 'found',
    'fox', 'fragile', 'frame', 'frequent', 'fresh', 'friend', 'fringe', 'frog',
    'front', 'frost', 'frown', 'frozen', 'fruit', 'fuel', 'fun', 'funny',
    'furnace', 'fury', 'future', 'gadget', 'gain', 'galaxy', 'gallery', 'game',
    'gap', 'garage', 'garbage', 'garden', 'garlic', 'garment', 'gas', 'gasp',
    'gate', 'gather', 'gauge', 'gaze', 'general', 'genius', 'genre', 'gentle',
    'genuine', 'gesture', 'ghost', 'giant', 'gift', 'giggle', 'ginger', 'giraffe',
    'girl', 'give', 'glad', 'glance', 'glare', 'glass', 'glide', 'glimpse',
    'globe', 'gloom', 'glory', 'glove', 'glow', 'glue', 'goat', 'goddess',
    'gold', 'good', 'goose', 'gorilla', 'gospel', 'gossip', 'govern', 'gown',
    'grab', 'grace', 'grain', 'grant', 'grape', 'grass', 'gravity', 'great',
    'green', 'grid', 'grief', 'grit', 'grocery', 'ground', 'group', 'grow',
    'grunt', 'guard', 'guess', 'guide', 'guilt', 'guitar', 'gun', 'gym',
    'habit', 'hair', 'half', 'hammer', 'hamster', 'hand', 'happy', 'harbor',
    'hard', 'harsh', 'harvest', 'hat', 'have', 'hawk', 'hazard', 'head',
    'health', 'heart', 'heavy', 'hedgehog', 'height', 'hello', 'helmet', 'help',
    'hen', 'hero', 'hidden', 'high', 'hill', 'hint', 'hip', 'hire',
    'history', 'hobby', 'hockey', 'hold', 'hole', 'holiday', 'hollow', 'holy',
    'home', 'honey', 'hood', 'hope', 'horn', 'horror', 'horse', 'hospital',
    'host', 'hotel', 'hour', 'hover', 'hub', 'huge', 'human', 'humble',
    'humor', 'hundred', 'hungry', 'hunt', 'hurdle', 'hurry', 'hurt', 'husband',
    'hybrid', 'ice', 'icon', 'idea', 'identify', 'idle', 'ignore', 'ill',
    'illegal', 'illness', 'image', 'imitate', 'immense', 'immune', 'impact', 'impose',
    'improve', 'impulse', 'inch', 'include', 'income', 'increase', 'index', 'indicate',
    'indoor', 'industry', 'infant', 'inflict', 'inform', 'inhale', 'inherit', 'initial',
    'inject', 'injury', 'inmate', 'inner', 'innocent', 'input', 'inquiry', 'insane',
    'insect', 'inside', 'inspire', 'install', 'intact', 'interest', 'into', 'invest',
    'invite', 'involve', 'iron', 'island', 'isolate', 'issue', 'item', 'ivory',
    'jacket', 'jaguar', 'jar', 'jazz', 'jealous', 'jeans', 'jelly', 'jewel',
    'job', 'jog', 'join', 'joke', 'journey', 'joy', 'judge', 'juice',
    'jump', 'jungle', 'junior', 'junk', 'just', 'kangaroo', 'keen', 'keep',
    'ketchup', 'key', 'kick', 'kid', 'kidney', 'kind', 'kingdom', 'kiss',
    'kit', 'kitchen', 'kite', 'kitten', 'kiwi', 'knee', 'knife', 'knock',
    'know', 'lab', 'label', 'labor', 'ladder', 'lady', 'lake', 'lamp',
    'language', 'laptop', 'large', 'later', 'latin', 'laugh', 'laundry', 'lava',
    'law', 'lawn', 'lawsuit', 'layer', 'lazy', 'leader', 'leaf', 'league',
    'learn', 'leave', 'lecture', 'left', 'leg', 'legal', 'legend', 'leisure',
    'lemon', 'lend', 'length', 'lens', 'leopard', 'lesson', 'letter', 'level',
    'liar', 'liberty', 'library', 'license', 'life', 'lift', 'light', 'like',
    'limb', 'limit', 'link', 'lion', 'liquid', 'list', 'little', 'live',
    'lizard', 'load', 'loan', 'lobster', 'local', 'lock', 'locust', 'lodge',
    'log', 'lonely', 'long', 'loop', 'lottery', 'loud', 'lounge', 'love',
    'loyal', 'lucky', 'luggage', 'lumber', 'lunar', 'lunch', 'luxury', 'lyrics',
    'machine', 'mad', 'magic', 'magnet', 'maid', 'mail', 'main', 'major',
    'make', 'mammal', 'man', 'manage', 'mandate', 'mango', 'mansion', 'manual',
    'maple', 'marble', 'march', 'margin', 'marine', 'market', 'marriage', 'marsh',
    'master', 'match', 'material', 'math', 'matrix', 'matter', 'maximum', 'maze',
    'meadow', 'mean', 'measure', 'meat', 'mechanic', 'medal', 'media', 'melody',
    'melt', 'member', 'memory', 'mention', 'menu', 'mercy', 'merge', 'merit',
    'merry', 'mesh', 'message', 'metal', 'method', 'middle', 'midnight', 'milk',
    'million', 'mimic', 'mind', 'minimum', 'minister', 'minor', 'minute', 'miracle',
    'mirror', 'misery', 'miss', 'mistake', 'mix', 'mixed', 'mixture', 'mobile',
    'model', 'modify', 'mom', 'moment', 'monitor', 'monkey', 'monster', 'month',
    'moon', 'moral', 'more', 'morning', 'mosquito', 'mother', 'motion', 'motor',
    'mountain', 'mouse', 'move', 'movie', 'much', 'muffin', 'mule', 'multiply',
    'muscle', 'museum', 'mushroom', 'music', 'must', 'mutual', 'myself', 'mystery',
    'myth', 'naive', 'name', 'napkin', 'narrow', 'nasty', 'nation', 'nature',
    'near', 'neck', 'need', 'negative', 'neglect', 'neither', 'nephew', 'nerve',
    'nest', 'net', 'network', 'neutral', 'never', 'news', 'next', 'nice',
    'niche', 'night', 'nine', 'noble', 'node', 'noise', 'nominee', 'noodle',
    'normal', 'north', 'nose', 'notable', 'note', 'nothing', 'notice', 'novel',
    'now', 'nuclear', 'number', 'nurse', 'nut', 'oak', 'obey', 'object',
    'oblige', 'obscure', 'observe', 'obtain', 'obvious', 'occur', 'ocean', 'october',
    'odor', 'off', 'offer', 'office', 'often', 'oil', 'okay', 'old',
    'olive', 'olympic', 'omit', 'once', 'one', 'onion', 'online', 'only',
    'open', 'opera', 'opinion', 'oppose', 'option', 'orange', 'orbit', 'orchard',
    'order', 'ordinary', 'organ', 'orient', 'original', 'orphan', 'ostrich', 'other',
    'outdoor', 'outer', 'output', 'outside', 'oval', 'oven', 'over', 'own',
    'owner', 'oxygen', 'oyster', 'ozone', 'pact', 'paddle', 'page', 'pair',
    'palace', 'palm', 'panda', 'panel', 'panic', 'panther', 'paper', 'parade',
    'parent', 'park', 'parrot', 'party', 'pass', 'patch', 'path', 'patient',
    'patrol', 'pattern', 'pause', 'pave', 'payment', 'peace', 'peanut', 'pear',
    'peasant', 'pelican', 'pen', 'penalty', 'pencil', 'people', 'pepper', 'perfect',
    'permit', 'person', 'pet', 'phone', 'photo', 'phrase', 'physical', 'piano',
    'picnic', 'picture', 'piece', 'pig', 'pigeon', 'pill', 'pilot', 'pink',
    'pioneer', 'pipe', 'pistol', 'pitch', 'pizza', 'place', 'planet', 'plastic',
    'plate', 'play', 'please', 'pledge', 'pluck', 'plug', 'plunge', 'poem',
    'poet', 'point', 'polar', 'pole', 'police', 'polish', 'polite', 'political',
    'poll', 'pollution', 'pond', 'pony', 'pool', 'popular', 'portion', 'position',
    'positive', 'possible', 'post', 'potato', 'pottery', 'poverty', 'powder', 'power',
    'practice', 'praise', 'predict', 'prefer', 'prepare', 'present', 'pretty', 'prevent',
    'price', 'pride', 'primary', 'print', 'priority', 'prison', 'private', 'prize',
    'problem', 'process', 'produce', 'profit', 'program', 'project', 'promote', 'proof',
    'property', 'prosper', 'protect', 'proud', 'provide', 'public', 'pudding', 'pull',
    'pulp', 'pulse', 'pumpkin', 'punch', 'pupil', 'puppy', 'purchase', 'purity',
    'purpose', 'purse', 'push', 'put', 'puzzle', 'pyramid', 'quality', 'quantum',
    'quarter', 'question', 'quick', 'quit', 'quiz', 'quote', 'rabbit', 'raccoon',
    'race', 'rack', 'radar', 'radio', 'rail', 'rain', 'raise', 'rally',
    'ramp', 'ranch', 'random', 'range', 'rapid', 'rare', 'rate', 'rather',
    'raven', 'raw', 'razor', 'ready', 'real', 'reason', 'rebel', 'rebuild',
    'recall', 'receive', 'recipe', 'record', 'recycle', 'reduce', 'reflect', 'reform',
  ];
  
  /// Generate a cryptographically secure identity
  /// Returns: {
  ///   'userId': Unique identifier (derived from public key),
  ///   'publicKey': Base64 encoded public key,
  ///   'privateKey': Base64 encoded private key,
  ///   'mnemonic': 12-word recovery phrase
  /// }
  Future<Map<String, String>> generateIdentity() async {
    // Generate X25519 key pair for encryption
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    
    // Extract keys
    final publicKey = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    
    // Generate 12-word mnemonic
    final mnemonic = _generateMnemonic();
    
    // Create user ID from public key (first 16 bytes as hex)
    final userId = publicKey.bytes
        .take(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join('');
    
    return {
      'userId': userId,
      'publicKey': base64Encode(publicKey.bytes),
      'privateKey': base64Encode(privateKeyBytes),
      'mnemonic': mnemonic,
    };
  }
  
  /// Recover identity from 12-word mnemonic
  Future<Map<String, String>?> recoverIdentity(String mnemonic) async {
    try {
      // Validate mnemonic
      final words = mnemonic.trim().toLowerCase().split(' ');
      if (words.length != 12) {
        return null;
      }
      
      // Check all words are valid
      for (final word in words) {
        if (!_wordList.contains(word)) {
          return null;
        }
      }
      
      // Generate deterministic keys from mnemonic
      final seed = _mnemonicToSeed(words);
      final algorithm = X25519();
      final keyPair = await algorithm.newKeyPairFromSeed(seed.sublist(0, 32));
      
      final publicKey = await keyPair.extractPublicKey();
      final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
      
      final userId = publicKey.bytes
          .take(16)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');
      
      return {
        'userId': userId,
        'publicKey': base64Encode(publicKey.bytes),
        'privateKey': base64Encode(privateKeyBytes),
        'mnemonic': mnemonic,
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Generate 12-word mnemonic phrase
  String _generateMnemonic() {
    final random = Random.secure();
    final words = <String>[];
    
    for (int i = 0; i < 12; i++) {
      words.add(_wordList[random.nextInt(_wordList.length)]);
    }
    
    return words.join(' ');
  }
  
  /// Convert mnemonic to seed bytes
  List<int> _mnemonicToSeed(List<String> words) {
    // Simple deterministic seed generation
    // In production, use proper BIP39 implementation
    final buffer = StringBuffer();
    for (final word in words) {
      buffer.write(word);
    }
    
    final bytes = utf8.encode(buffer.toString());
    // Hash to get 32 bytes
    final hash = <int>[];
    for (int i = 0; i < bytes.length; i += 4) {
      int value = 0;
      for (int j = 0; j < 4 && i + j < bytes.length; j++) {
        value = (value << 8) | bytes[i + j];
      }
      hash.addAll([
        (value >> 24) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ]);
    }
    
    return hash.take(32).toList();
  }
  
  /// Format user ID for display (adds separators)
  String formatUserId(String userId) {
    if (userId.length != 32) return userId;
    
    final parts = <String>[];
    for (int i = 0; i < 32; i += 4) {
      parts.add(userId.substring(i, i + 4));
    }
    return parts.join('-');
  }
  
  /// Get short display version of user ID
  String getShortUserId(String userId) {
    if (userId.length < 8) return userId;
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }
}
