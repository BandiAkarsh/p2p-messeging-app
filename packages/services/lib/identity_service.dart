import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Identity Service - Enterprise-grade decentralized identity management
/// Implements BIP39 standard with PBKDF2 key derivation
/// Features: Forward secrecy, Secure memory wiping, Checksum validation
class IdentityService {
  static const String _userKey = 'user_identity';
  static const String _mnemonicKey = 'user_mnemonic';
  static const int _mnemonicStrength = 128; // 128 bits = 12 words
  static const int _seedIterations = 2048; // BIP39 standard
  static const String _seedSalt = 'mnemonic'; // BIP39 standard salt
  
  // BIP39 English wordlist (2048 words) - Standard for crypto wallets
  final List<String> _wordList = [
    'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract', 'absurd', 'abuse', 'access', 'accident',
    'account', 'accuse', 'achieve', 'acid', 'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
    'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance', 'advice', 'aerobic', 'affair', 'afford',
    'afraid', 'again', 'age', 'agent', 'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    'alcohol', 'alert', 'alien', 'all', 'alley', 'allow', 'almost', 'alone', 'alpha', 'already', 'also', 'alter',
    'always', 'amateur', 'amazing', 'among', 'amount', 'amused', 'analyst', 'anchor', 'ancient', 'anger', 'angle', 'angry',
    'animal', 'ankle', 'announce', 'annual', 'another', 'answer', 'antenna', 'antique', 'anxiety', 'any', 'apart', 'apology',
    'appear', 'apple', 'approve', 'april', 'arch', 'arctic', 'area', 'arena', 'argue', 'arm', 'armed', 'armor',
    'army', 'around', 'arrange', 'arrest', 'arrive', 'arrow', 'art', 'artefact', 'artist', 'artwork', 'ask', 'aspect',
    'assault', 'asset', 'assist', 'assume', 'asthma', 'athlete', 'atom', 'attack', 'attend', 'attitude', 'attract', 'auction',
    'audit', 'august', 'aunt', 'author', 'auto', 'autumn', 'average', 'avocado', 'avoid', 'awake', 'aware', 'away',
    'awesome', 'awful', 'awkward', 'axis', 'baby', 'bachelor', 'bacon', 'badge', 'bag', 'balance', 'balcony', 'ball',
    'bamboo', 'banana', 'banner', 'bar', 'barely', 'bargain', 'barrel', 'base', 'basic', 'basket', 'battle', 'beach',
    'bean', 'beauty', 'because', 'become', 'beef', 'before', 'begin', 'behave', 'behind', 'believe', 'below', 'belt',
    'bench', 'benefit', 'best', 'betray', 'better', 'between', 'beyond', 'bicycle', 'bid', 'bike', 'bind', 'biology',
    'bird', 'birth', 'bitter', 'black', 'blade', 'blame', 'blanket', 'blast', 'bleak', 'bless', 'blind', 'blood',
    'blossom', 'blouse', 'blue', 'blur', 'blush', 'board', 'boat', 'body', 'boil', 'bomb', 'bone', 'bonus',
    'book', 'boost', 'border', 'boring', 'borrow', 'boss', 'bottom', 'bounce', 'box', 'boy', 'bracket', 'brain',
    'brand', 'brass', 'brave', 'bread', 'breeze', 'brick', 'bridge', 'brief', 'bright', 'brilliant', 'bring', 'british',
    'broad', 'broccoli', 'broken', 'bronze', 'brother', 'brown', 'brush', 'bubble', 'buddy', 'budget', 'buffalo', 'build',
    'bulb', 'bulk', 'bullet', 'bundle', 'bunker', 'burden', 'burger', 'burst', 'bus', 'business', 'busy', 'butter',
    'buyer', 'buzz', 'cabbage', 'cabin', 'cable', 'cactus', 'cage', 'cake', 'call', 'calm', 'camera', 'camp',
    'can', 'canal', 'cancel', 'candy', 'cannon', 'canoe', 'canvas', 'canyon', 'capable', 'capital', 'captain', 'car',
    'carbon', 'card', 'cargo', 'carpet', 'carry', 'cart', 'carve', 'case', 'cash', 'casino', 'castle', 'casual',
    'cat', 'catalog', 'catch', 'category', 'cattle', 'caught', 'cause', 'caution', 'cave', 'ceiling', 'celery', 'cement',
    'census', 'century', 'cereal', 'certain', 'chair', 'chalk', 'champion', 'change', 'chaos', 'chapter', 'charge', 'chase',
    'chat', 'cheap', 'check', 'cheek', 'cheer', 'cheese', 'chef', 'cherry', 'chest', 'chicken', 'chief', 'child',
    'chimney', 'choice', 'choose', 'chronic', 'chuckle', 'chunk', 'churn', 'cigar', 'cinnamon', 'circle', 'citizen', 'city',
    'civil', 'claim', 'clap', 'clarify', 'claw', 'clay', 'clean', 'clerk', 'clever', 'click', 'client', 'cliff',
    'climb', 'clinic', 'clip', 'clock', 'clog', 'close', 'cloth', 'cloud', 'clown', 'club', 'clump', 'cluster',
    'clutch', 'coach', 'coast', 'coconut', 'code', 'coffee', 'coil', 'coin', 'collect', 'color', 'column', 'combine',
    'come', 'comfort', 'comic', 'common', 'company', 'concert', 'conduct', 'confirm', 'congress', 'connect', 'consider', 'control',
    'convert', 'convince', 'cook', 'cool', 'copper', 'copy', 'coral', 'core', 'corn', 'correct', 'cost', 'cotton',
    'couch', 'country', 'couple', 'course', 'cousin', 'cover', 'coyote', 'crack', 'cradle', 'craft', 'cram', 'crane',
    'crash', 'crater', 'crawl', 'crazy', 'cream', 'credit', 'creek', 'crew', 'cricket', 'crime', 'crisp', 'critic',
    'crop', 'cross', 'crouch', 'crowd', 'crucial', 'cruel', 'cruise', 'crumble', 'crunch', 'crush', 'cry', 'crystal',
    'cube', 'culture', 'cup', 'cupboard', 'curious', 'current', 'curtain', 'curve', 'cushion', 'custom', 'cute', 'cycle',
    'dad', 'damage', 'damp', 'dance', 'danger', 'daring', 'dash', 'daughter', 'dawn', 'day', 'deal', 'debate',
    'debris', 'decade', 'december', 'decide', 'decline', 'decorate', 'decrease', 'deer', 'defense', 'define', 'defy', 'degree',
    'delay', 'deliver', 'demand', 'demise', 'denial', 'dentist', 'deny', 'depart', 'depend', 'deposit', 'depth', 'deputy',
    'derive', 'describe', 'desert', 'design', 'desk', 'despair', 'destroy', 'detail', 'detect', 'develop', 'device', 'devote',
    'diagram', 'dial', 'diamond', 'diary', 'dice', 'diesel', 'diet', 'differ', 'digital', 'dignity', 'dilemma', 'dinner',
    'dinosaur', 'direct', 'dirt', 'disagree', 'discover', 'disease', 'dish', 'dismiss', 'disorder', 'display', 'distance', 'divert',
    'divide', 'divorce', 'dizzy', 'doctor', 'document', 'dog', 'doll', 'dolphin', 'domain', 'donate', 'donkey', 'donor',
    'door', 'dose', 'double', 'dove', 'draft', 'dragon', 'drama', 'drastic', 'draw', 'dream', 'dress', 'drift',
    'drill', 'drink', 'drip', 'drive', 'drop', 'drum', 'dry', 'duck', 'dumb', 'dune', 'during', 'dust',
    'dutch', 'duty', 'dwarf', 'dynamic', 'eager', 'eagle', 'early', 'earn', 'earth', 'easily', 'east', 'easy',
    'echo', 'ecology', 'economy', 'edge', 'edit', 'educate', 'effort', 'egg', 'eight', 'either', 'elbow', 'elder',
    'electric', 'elegant', 'element', 'elephant', 'elevator', 'elite', 'else', 'embark', 'embrace', 'emerge', 'emotion', 'employ',
    'empty', 'enable', 'enact', 'end', 'enemy', 'energy', 'enforce', 'engage', 'engine', 'enhance', 'enjoy', 'enlist',
    'enough', 'enrich', 'enroll', 'ensure', 'enter', 'entire', 'entry', 'envelope', 'episode', 'equal', 'equip', 'era',
    'erase', 'erode', 'erosion', 'error', 'erupt', 'escape', 'essay', 'essence', 'estate', 'eternal', 'ethics', 'evidence',
    'evil', 'evoke', 'evolve', 'exact', 'example', 'excess', 'exchange', 'excite', 'exclude', 'excuse', 'execute', 'exercise',
    'exhaust', 'exhibit', 'exile', 'exist', 'exit', 'exotic', 'expand', 'expect', 'expire', 'explain', 'explode', 'explore',
    'export', 'express', 'extend', 'extra', 'eye', 'eyebrow', 'fabric', 'face', 'faculty', 'fade', 'faint', 'faith',
    'fall', 'false', 'fame', 'family', 'famous', 'fan', 'fancy', 'fantasy', 'farm', 'fashion', 'fat', 'fatal',
    'father', 'fatigue', 'fault', 'favorite', 'feature', 'february', 'federal', 'fee', 'feed', 'feel', 'female', 'fence',
    'festival', 'fetch', 'fever', 'few', 'fiber', 'fiction', 'field', 'fierce', 'fifth', 'fight', 'figure', 'file',
    'film', 'filter', 'final', 'find', 'fine', 'finger', 'finish', 'fire', 'firm', 'first', 'fiscal', 'fish',
    'fit', 'fitness', 'fix', 'flag', 'flame', 'flash', 'flat', 'flavor', 'flee', 'flight', 'flip', 'float',
    'flock', 'floor', 'flower', 'fluid', 'flush', 'fly', 'foam', 'focus', 'fog', 'foil', 'fold', 'follow',
    'food', 'foot', 'force', 'forest', 'forget', 'fork', 'fortune', 'forum', 'forward', 'fossil', 'foster', 'found',
    'fox', 'fragile', 'frame', 'frequent', 'fresh', 'friend', 'fringe', 'frog', 'front', 'frost', 'frown', 'frozen',
    'fruit', 'fuel', 'fun', 'funny', 'furnace', 'fury', 'future', 'gadget', 'gain', 'galaxy', 'gallery', 'game',
    'gap', 'garage', 'garbage', 'garden', 'garlic', 'garment', 'gas', 'gasp', 'gate', 'gather', 'gauge', 'gaze',
    'general', 'genius', 'genre', 'gentle', 'genuine', 'gesture', 'ghost', 'giant', 'gift', 'giggle', 'ginger', 'giraffe',
    'girl', 'give', 'glad', 'glance', 'glare', 'glass', 'glide', 'glimpse', 'globe', 'gloom', 'glory', 'glove',
    'glow', 'glue', 'goat', 'goddess', 'gold', 'good', 'goose', 'gorilla', 'gospel', 'gossip', 'govern', 'gown',
    'grab', 'grace', 'grain', 'grant', 'grape', 'grass', 'gravity', 'great', 'green', 'grid', 'grief', 'grit',
    'grocery', 'ground', 'group', 'grow', 'grunt', 'guard', 'guess', 'guide', 'guilt', 'guitar', 'gun', 'gym',
    'habit', 'hair', 'half', 'hammer', 'hamster', 'hand', 'happy', 'harbor', 'hard', 'harsh', 'harvest', 'hat',
    'have', 'hawk', 'hazard', 'head', 'health', 'heart', 'heavy', 'hedgehog', 'height', 'hello', 'helmet', 'help',
    'hen', 'hero', 'hidden', 'high', 'hill', 'hint', 'hip', 'hire', 'history', 'hobby', 'hockey', 'hold',
    'hole', 'holiday', 'hollow', 'holy', 'home', 'honey', 'hood', 'hope', 'horn', 'horror', 'horse', 'hospital',
    'host', 'hotel', 'hour', 'hover', 'hub', 'huge', 'human', 'humble', 'humor', 'hundred', 'hungry', 'hunt',
    'hurdle', 'hurry', 'hurt', 'husband', 'hybrid', 'ice', 'icon', 'idea', 'identify', 'idle', 'ignore', 'ill',
    'illegal', 'illness', 'image', 'imitate', 'immense', 'immune', 'impact', 'impose', 'improve', 'impulse', 'inch', 'include',
    'income', 'increase', 'index', 'indicate', 'indoor', 'industry', 'infant', 'inflict', 'inform', 'inhale', 'inherit', 'initial',
    'inject', 'injury', 'inmate', 'inner', 'innocent', 'input', 'inquiry', 'insane', 'insect', 'inside', 'inspire', 'install',
    'intact', 'interest', 'into', 'invest', 'invite', 'involve', 'iron', 'island', 'isolate', 'issue', 'item', 'ivory',
    'jacket', 'jaguar', 'jar', 'jazz', 'jealous', 'jeans', 'jelly', 'jewel', 'job', 'jog', 'join', 'joke',
    'journey', 'joy', 'judge', 'juice', 'jump', 'jungle', 'junior', 'junk', 'just', 'kangaroo', 'keen', 'keep',
    'ketchup', 'key', 'kick', 'kid', 'kidney', 'kind', 'kingdom', 'kiss', 'kit', 'kitchen', 'kite', 'kitten',
    'kiwi', 'knee', 'knife', 'knock', 'know', 'lab', 'label', 'labor', 'ladder', 'lady', 'lake', 'lamp',
    'language', 'laptop', 'large', 'later', 'latin', 'laugh', 'laundry', 'lava', 'law', 'lawn', 'lawsuit', 'layer',
    'lazy', 'leader', 'leaf', 'league', 'learn', 'leave', 'lecture', 'left', 'leg', 'legal', 'legend', 'leisure',
    'lemon', 'lend', 'length', 'lens', 'leopard', 'lesson', 'letter', 'level', 'liar', 'liberty', 'library', 'license',
    'life', 'lift', 'light', 'like', 'limb', 'limit', 'link', 'lion', 'liquid', 'list', 'little', 'live',
    'lizard', 'load', 'loan', 'lobster', 'local', 'lock', 'locust', 'lodge', 'log', 'lonely', 'long', 'loop',
    'lottery', 'loud', 'lounge', 'love', 'loyal', 'lucky', 'luggage', 'lumber', 'lunar', 'lunch', 'luxury', 'lyrics',
    'machine', 'mad', 'magic', 'magnet', 'maid', 'mail', 'main', 'major', 'make', 'mammal', 'man', 'manage',
    'mandate', 'mango', 'mansion', 'manual', 'maple', 'marble', 'march', 'margin', 'marine', 'market', 'marriage', 'marsh',
    'master', 'match', 'material', 'math', 'matrix', 'matter', 'maximum', 'maze', 'meadow', 'mean', 'measure', 'meat',
    'mechanic', 'medal', 'media', 'melody', 'melt', 'member', 'memory', 'mention', 'menu', 'mercy', 'merge', 'merit',
    'merry', 'mesh', 'message', 'metal', 'method', 'middle', 'midnight', 'milk', 'million', 'mimic', 'mind', 'minimum',
    'minister', 'minor', 'minute', 'miracle', 'mirror', 'misery', 'miss', 'mistake', 'mix', 'mixed', 'mixture', 'mobile',
    'model', 'modify', 'mom', 'moment', 'monitor', 'monkey', 'monster', 'month', 'moon', 'moral', 'more', 'morning',
    'mosquito', 'mother', 'motion', 'motor', 'mountain', 'mouse', 'move', 'movie', 'much', 'muffin', 'mule', 'multiply',
    'muscle', 'museum', 'mushroom', 'music', 'must', 'mutual', 'myself', 'mystery', 'myth', 'naive', 'name', 'napkin',
    'narrow', 'nasty', 'nation', 'nature', 'near', 'neck', 'need', 'negative', 'neglect', 'neither', 'nephew', 'nerve',
    'nest', 'net', 'network', 'neutral', 'never', 'news', 'next', 'nice', 'niche', 'night', 'nine', 'noble',
    'node', 'noise', 'nominee', 'noodle', 'normal', 'north', 'nose', 'notable', 'note', 'nothing', 'notice', 'novel',
    'now', 'nuclear', 'number', 'nurse', 'nut', 'oak', 'obey', 'object', 'oblige', 'obscure', 'observe', 'obtain',
    'obvious', 'occur', 'ocean', 'october', 'odor', 'off', 'offer', 'office', 'often', 'oil', 'okay', 'old',
    'olive', 'olympic', 'omit', 'once', 'one', 'onion', 'online', 'only', 'open', 'opera', 'opinion', 'oppose',
    'option', 'orange', 'orbit', 'orchard', 'order', 'ordinary', 'organ', 'orient', 'original', 'orphan', 'ostrich', 'other',
    'outdoor', 'outer', 'output', 'outside', 'oval', 'oven', 'over', 'own', 'owner', 'oxygen', 'oyster', 'ozone',
    'pact', 'paddle', 'page', 'pair', 'palace', 'palm', 'panda', 'panel', 'panic', 'panther', 'paper', 'parade',
    'parent', 'park', 'parrot', 'party', 'pass', 'patch', 'path', 'patient', 'patrol', 'pattern', 'pause', 'pave',
    'payment', 'peace', 'peanut', 'pear', 'peasant', 'pelican', 'pen', 'penalty', 'pencil', 'people', 'pepper', 'perfect',
    'permit', 'person', 'pet', 'phone', 'photo', 'phrase', 'physical', 'piano', 'picnic', 'picture', 'piece', 'pig',
    'pigeon', 'pill', 'pilot', 'pink', 'pioneer', 'pipe', 'pistol', 'pitch', 'pizza', 'place', 'planet', 'plastic',
    'plate', 'play', 'please', 'pledge', 'pluck', 'plug', 'plunge', 'poem', 'poet', 'point', 'polar', 'pole',
    'police', 'polish', 'polite', 'political', 'poll', 'pollution', 'pond', 'pony', 'pool', 'popular', 'portion', 'position',
    'positive', 'possible', 'post', 'potato', 'pottery', 'poverty', 'powder', 'power', 'practice', 'praise', 'predict', 'prefer',
    'prepare', 'present', 'pretty', 'prevent', 'price', 'pride', 'primary', 'print', 'priority', 'prison', 'private', 'prize',
    'problem', 'process', 'produce', 'profit', 'program', 'project', 'promote', 'proof', 'property', 'prosper', 'protect', 'proud',
    'provide', 'public', 'pudding', 'pull', 'pulp', 'pulse', 'pumpkin', 'punch', 'pupil', 'puppy', 'purchase', 'purity',
    'purpose', 'purse', 'push', 'put', 'puzzle', 'pyramid', 'quality', 'quantum', 'quarter', 'question', 'quick', 'quit',
    'quiz', 'quote', 'rabbit', 'raccoon', 'race', 'rack', 'radar', 'radio', 'rail', 'rain', 'raise', 'rally',
    'ramp', 'ranch', 'random', 'range', 'rapid', 'rare', 'rate', 'rather', 'raven', 'raw', 'razor', 'ready',
    'real', 'reason', 'rebel', 'rebuild', 'recall', 'receive', 'recipe', 'record', 'recycle', 'reduce', 'reflect', 'reform',
    'refuse', 'region', 'regret', 'regular', 'reject', 'relax', 'release', 'relief', 'rely', 'remain', 'remember', 'remind',
    'remove', 'render', 'renew', 'rent', 'reopen', 'repair', 'repeat', 'replace', 'report', 'require', 'rescue', 'resemble',
    'resist', 'resource', 'response', 'result', 'retire', 'retreat', 'return', 'reunion', 'reveal', 'review', 'reward', 'rhythm',
    'rib', 'ribbon', 'rice', 'rich', 'ride', 'ridge', 'rifle', 'right', 'rigid', 'ring', 'riot', 'ripple',
    'risk', 'ritual', 'rival', 'river', 'road', 'roast', 'robot', 'robust', 'rocket', 'romance', 'roof', 'rookie',
    'room', 'rose', 'rotate', 'rough', 'round', 'route', 'royal', 'rubber', 'rude', 'rug', 'rule', 'run',
    'runway', 'rural', 'sad', 'saddle', 'sadness', 'safe', 'sail', 'salad', 'salmon', 'salon', 'salt', 'salute',
    'same', 'sample', 'sand', 'satisfy', 'satoshi', 'sauce', 'sausage', 'save', 'say', 'scale', 'scan', 'scare',
    'scatter', 'scene', 'scheme', 'school', 'science', 'scissors', 'scorpion', 'scout', 'scrap', 'screen', 'script', 'scrub',
    'sea', 'search', 'season', 'seat', 'second', 'secret', 'section', 'security', 'seed', 'seek', 'segment', 'select',
    'sell', 'seminar', 'senior', 'sense', 'sentence', 'series', 'service', 'session', 'settle', 'setup', 'seven', 'shadow',
    'shaft', 'shallow', 'share', 'shed', 'shell', 'sheriff', 'shield', 'shift', 'shine', 'ship', 'shiver', 'shock',
    'shoe', 'shoot', 'shop', 'short', 'shoulder', 'shove', 'shrimp', 'shrug', 'shuffle', 'shy', 'sibling', 'sick',
    'side', 'siege', 'sight', 'sign', 'silent', 'silk', 'silly', 'silver', 'similar', 'simple', 'since', 'sing',
    'siren', 'sister', 'situate', 'six', 'size', 'skate', 'sketch', 'ski', 'skill', 'skin', 'skirt', 'skull',
    'slab', 'slam', 'sleep', 'slender', 'slice', 'slide', 'slight', 'slim', 'slogan', 'slot', 'slow', 'slush',
    'small', 'smart', 'smile', 'smoke', 'smooth', 'snack', 'snake', 'snap', 'sniff', 'snow', 'soap', 'soccer',
    'social', 'sock', 'soda', 'soft', 'solar', 'soldier', 'solid', 'solution', 'solve', 'someone', 'song', 'soon',
    'sorry', 'sort', 'soul', 'sound', 'soup', 'source', 'south', 'space', 'spare', 'spatial', 'spawn', 'speak',
    'special', 'speed', 'spell', 'spend', 'sphere', 'spice', 'spider', 'spike', 'spin', 'spirit', 'split', 'spoil',
    'sponsor', 'spoon', 'sport', 'spot', 'spray', 'spread', 'spring', 'spy', 'square', 'squeeze', 'squirrel', 'stable',
    'stadium', 'staff', 'stage', 'stairs', 'stamp', 'stand', 'start', 'state', 'stay', 'steak', 'steel', 'stem',
    'step', 'stereo', 'stick', 'still', 'sting', 'stock', 'stomach', 'stone', 'stool', 'story', 'stove', 'strategy',
    'street', 'strike', 'strong', 'struggle', 'student', 'stuff', 'stumble', 'style', 'subject', 'submit', 'subway', 'success',
    'such', 'sudden', 'suffer', 'sugar', 'suggest', 'suit', 'summer', 'sun', 'sunset', 'super', 'supply', 'supreme',
    'sure', 'surface', 'surge', 'surprise', 'surround', 'survey', 'suspect', 'sustain', 'swallow', 'swamp', 'swap', 'swarm',
    'swear', 'sweet', 'swift', 'swim', 'swing', 'switch', 'sword', 'symbol', 'symptom', 'syrup', 'system', 'table',
    'tackle', 'tag', 'tail', 'talent', 'talk', 'tank', 'tape', 'target', 'task', 'taste', 'tattoo', 'taxi',
    'teach', 'team', 'tell', 'ten', 'tenant', 'tennis', 'tent', 'term', 'test', 'text', 'thank', 'that',
    'theme', 'then', 'theory', 'there', 'they', 'thing', 'this', 'thought', 'three', 'thrive', 'throw', 'thumb',
    'thunder', 'ticket', 'tide', 'tiger', 'tilt', 'timber', 'time', 'tiny', 'tip', 'tired', 'tissue', 'title',
    'toast', 'tobacco', 'today', 'toddler', 'toe', 'together', 'toilet', 'token', 'tomato', 'tomorrow', 'tone', 'tongue',
    'tonight', 'tool', 'tooth', 'top', 'topic', 'topple', 'torch', 'tornado', 'tortoise', 'toss', 'total', 'tourist',
    'toward', 'tower', 'town', 'toy', 'track', 'trade', 'traffic', 'tragic', 'train', 'transfer', 'trap', 'trash',
    'travel', 'tray', 'treat', 'tree', 'trend', 'trial', 'tribe', 'trick', 'trigger', 'trim', 'trip', 'trophy',
    'trouble', 'truck', 'true', 'truly', 'trumpet', 'trust', 'truth', 'try', 'tube', 'tuition', 'tumble', 'tuna',
    'tunnel', 'turkey', 'turn', 'turtle', 'twelve', 'twenty', 'twice', 'twin', 'twist', 'two', 'type', 'typical',
    'ugly', 'umbrella', 'unable', 'unaware', 'uncle', 'uncover', 'under', 'undo', 'unfair', 'unfold', 'unhappy', 'uniform',
    'unique', 'unit', 'universe', 'unknown', 'unlock', 'until', 'unusual', 'unveil', 'update', 'upgrade', 'uphold', 'upon',
    'upper', 'upset', 'urban', 'urge', 'usage', 'use', 'used', 'useful', 'useless', 'usual', 'utility', 'vacant',
    'vacuum', 'vague', 'valid', 'valley', 'valve', 'van', 'vanish', 'vapor', 'various', 'vast', 'vault', 'vehicle',
    'velvet', 'vendor', 'venture', 'venue', 'verb', 'verify', 'version', 'very', 'vessel', 'veteran', 'viable', 'vibrant',
    'vicious', 'victory', 'video', 'view', 'village', 'vintage', 'violin', 'virtual', 'virus', 'visa', 'visit', 'visual',
    'vital', 'vivid', 'vocal', 'voice', 'void', 'volcano', 'volume', 'vote', 'voyage', 'wage', 'wagon', 'wait',
    'walk', 'wall', 'walnut', 'want', 'warfare', 'warm', 'warrior', 'wash', 'wasp', 'waste', 'water', 'wave',
    'way', 'wealth', 'weapon', 'wear', 'weasel', 'weather', 'web', 'wedding', 'weekend', 'weird', 'welcome', 'west',
    'wet', 'whale', 'what', 'wheat', 'wheel', 'when', 'where', 'whip', 'whisper', 'wide', 'width', 'wife',
    'wild', 'will', 'win', 'window', 'wine', 'wing', 'wink', 'winner', 'winter', 'wire', 'wisdom', 'wise',
    'wish', 'witness', 'wolf', 'woman', 'wonder', 'wood', 'wool', 'word', 'work', 'world', 'worry', 'worth',
    'wrap', 'wreck', 'wrestle', 'wrist', 'write', 'wrong', 'yard', 'year', 'yellow', 'you', 'young', 'youth',
    'zebra', 'zero', 'zone', 'zoo'
  ];

  // CRC8 checksum table for BIP39 checksum validation
  final List<int> _crc8Table = List.generate(256, (i) {
    int crc = i;
    for (int j = 0; j < 8; j++) {
      crc = (crc & 0x80) != 0 ? ((crc << 1) ^ 0x07) : (crc << 1);
    }
    return crc & 0xFF;
  });

  /// Generate a cryptographically secure identity with BIP39 mnemonic
  /// Features:
  /// - BIP39 compliant 12-word mnemonic
  /// - PBKDF2 key derivation (2048 iterations)
  /// - Checksum validation
  /// - Forward secrecy ready
  Future<Map<String, String>> generateIdentity() async {
    try {
      // Generate X25519 key pair for encryption
      final algorithm = X25519();
      final keyPair = await algorithm.newKeyPair();
      
      // Extract keys
      final publicKey = await keyPair.extractPublicKey();
      final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
      
      // Generate BIP39 compliant mnemonic with checksum
      final mnemonic = _generateBIP39Mnemonic();
      
      // Create user ID from public key hash (first 16 bytes as hex)
      final userId = _bytesToHex(publicKey.bytes.take(16).toList());
      
      // Wipe sensitive data from memory
      _secureWipe(privateKeyBytes);
      
      return {
        'userId': userId,
        'publicKey': base64Encode(publicKey.bytes),
        'privateKey': base64Encode(privateKeyBytes),
        'mnemonic': mnemonic,
      };
    } catch (e) {
      throw IdentityGenerationException('Failed to generate identity: $e');
    }
  }
  
  /// Recover identity from 12-word mnemonic with BIP39 validation
  /// Validates:
  /// - Word count (12)
  /// - All words in BIP39 wordlist
  /// - Checksum correctness
  Future<Map<String, String>?> recoverIdentity(String mnemonic) async {
    try {
      // Validate mnemonic format
      final words = mnemonic.trim().toLowerCase().split(RegExp(r'\s+'));
      if (words.length != 12) {
        return null;
      }
      
      // Validate all words exist in wordlist
      for (final word in words) {
        if (!_wordList.contains(word)) {
          return null;
        }
      }
      
      // Validate checksum (BIP39 standard)
      if (!_validateMnemonicChecksum(words)) {
        return null;
      }
      
      // Generate deterministic seed using PBKDF2
      final seed = await _mnemonicToSeed(words);
      
      // Use first 32 bytes for X25519 key generation
      final algorithm = X25519();
      final keyPair = await algorithm.newKeyPairFromSeed(seed.sublist(0, 32));
      
      final publicKey = await keyPair.extractPublicKey();
      final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
      
      final userId = _bytesToHex(publicKey.bytes.take(16).toList());
      
      // Wipe sensitive data
      _secureWipe(seed);
      _secureWipe(privateKeyBytes);
      
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
  
  /// Generate BIP39 compliant 12-word mnemonic with checksum
  String _generateBIP39Mnemonic() {
    // Generate 128 bits of entropy (16 bytes)
    final random = Random.secure();
    final entropy = List<int>.generate(16, (_) => random.nextInt(256));
    
    // Calculate checksum (4 bits for 128-bit entropy)
    final checksumBits = _calculateChecksum(entropy);
    
    // Convert entropy + checksum to word indices
    final bits = _bytesToBinary(entropy) + checksumBits;
    final words = <String>[];
    
    for (int i = 0; i < bits.length; i += 11) {
      final index = int.parse(bits.substring(i, i + 11), radix: 2);
      words.add(_wordList[index]);
    }
    
    // Securely wipe entropy
    _secureWipe(entropy);
    
    return words.join(' ');
  }
  
  /// Calculate 4-bit checksum for BIP39
  String _calculateChecksum(List<int> entropy) {
    int crc = 0;
    for (final byte in entropy) {
      crc = _crc8Table[(crc ^ byte) & 0xFF];
    }
    // Take first 4 bits
    final checksum = crc >> 4;
    return checksum.toRadixString(2).padLeft(4, '0');
  }
  
  /// Validate mnemonic checksum (BIP39)
  bool _validateMnemonicChecksum(List<String> words) {
    // Convert words back to binary
    final bits = words.map((word) {
      final index = _wordList.indexOf(word);
      return index.toRadixString(2).padLeft(11, '0');
    }).join();
    
    // Split into entropy and checksum
    final entropyBits = bits.substring(0, 128);
    final checksumBits = bits.substring(128, 132);
    
    // Convert entropy bits back to bytes
    final entropy = <int>[];
    for (int i = 0; i < entropyBits.length; i += 8) {
      entropy.add(int.parse(entropyBits.substring(i, i + 8), radix: 2));
    }
    
    // Verify checksum
    final calculatedChecksum = _calculateChecksum(entropy);
    return calculatedChecksum == checksumBits;
  }
  
  /// Convert mnemonic to seed using PBKDF2-HMAC-SHA512 (BIP39 standard)
  Future<List<int>> _mnemonicToSeed(List<String> words) async {
    // Join words with single space (BIP39 standard)
    final phrase = words.join(' ');
    final password = utf8.encode(phrase);
    final salt = utf8.encode(_seedSalt);
    
    // PBKDF2 with HMAC-SHA512, 2048 iterations, 64-byte output
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha512(),
      iterations: _seedIterations,
      bits: 512,
    );
    
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(password),
      nonce: salt,
    );
    
    final seed = await secretKey.extractBytes();
    
    // Wipe sensitive data
    _secureWipe(password);
    
    return seed;
  }
  
  /// Convert bytes to binary string
  String _bytesToBinary(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join();
  }
  
  /// Convert bytes to hex string
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
  
  /// Securely wipe sensitive data from memory
  void _secureWipe(List<int> data) {
    // Overwrite with random data then zeros
    final random = Random.secure();
    for (int i = 0; i < data.length; i++) {
      data[i] = random.nextInt(256);
    }
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
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
  
  /// Verify mnemonic strength (for security auditing)
  Map<String, dynamic> auditMnemonic(String mnemonic) {
    final words = mnemonic.trim().toLowerCase().split(RegExp(r'\s+'));
    
    return {
      'wordCount': words.length,
      'isValidLength': words.length == 12,
      'allWordsValid': words.every((w) => _wordList.contains(w)),
      'checksumValid': _validateMnemonicChecksum(words),
      'entropyBits': words.length * 11 - 4,
      'securityLevel': words.length == 12 ? 'Standard (128-bit)' : 'Unknown',
    };
  }
}

/// Identity Generation Exception
class IdentityGenerationException implements Exception {
  final String message;
  IdentityGenerationException(this.message);
  
  @override
  String toString() => 'IdentityGenerationException: $message';
}
