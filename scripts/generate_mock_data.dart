import 'dart:convert';
import 'dart:io';

/// Script pour générer des données mock complètes pour le serveur JSON
/// 
/// Usage: dart run scripts/generate_mock_data.dart
void main() {
  print('🚀 Génération des données mock...\n');

  final data = {
    'posts': _generatePosts(),
    'profiles': _generateProfiles(),
    'chats': _generateChats(),
    'messages': _generateMessages(),
    'comments': _generateComments(),
    'notifications': _generateNotifications(),
  };

  final jsonString = JsonEncoder.withIndent('  ').convert(data);
  
  final file = File('db.json');
  file.writeAsStringSync(jsonString);

  print('✅ Fichier db.json généré avec succès!');
  print('📊 Statistiques:');
  print('   - ${data['posts'].length} posts');
  print('   - ${data['profiles'].length} profils');
  print('   - ${data['chats'].length} chats');
  print('   - ${data['messages'].length} messages');
  print('   - ${data['comments'].length} commentaires');
  print('   - ${data['notifications'].length} notifications');
  print('\n🎯 Vous pouvez maintenant démarrer le serveur avec: npm start');
}

List<Map<String, dynamic>> _generatePosts() {
  final now = DateTime.now();
  final posts = <Map<String, dynamic>>[];

  final contents = [
    'Nouvelle fonctionnalité Flutter 3.16 disponible ! 🚀\n\nLes animations sont maintenant 40% plus fluides. #Flutter #Dev',
    'Quand le boss final te dit "gg ez" après t\'avoir tué 47 fois... 😤 #Gaming #Perseverance',
    'La programmation, c\'est comme la cuisine 👨‍🍳\n\nTu improvises et tu crées les meilleurs plats ! ✨ #CodeLife',
    'Excellente présentation aujourd\'hui sur l\'architecture microservices ! 🏗️ #Tech #Architecture',
    'Tutoriel rapide : Comment optimiser vos requêtes SQL en 3 étapes ! ⚡ #SQL #Database',
    'Moi quand je réussis enfin ce combo impossible après 200 essais 🎮 #Gaming #Victory',
    'Dans l\'ombre, nous codons. Dans la lumière, nous déployons. 🥷 #Ninja #Code',
    'Les 5 principes SOLID expliqués avec des exemples concrets ! 📚 #SOLID #CleanCode',
    '💪 MOTIVATION DU JOUR 💪\n\n"Le code que tu écris aujourd\'hui détermine le développeur que tu seras demain." #Motivation',
    'Deep dive dans les WebAssembly modules ! 🌐 Performance native ⚡ #WebAssembly #Performance',
  ];

  for (var i = 0; i < 50; i++) {
    final hoursAgo = i * 2;
    posts.add({
      'id': 'post_${i + 1}',
      'authorId': 'user_${(i % 10) + 1}',
      'authorName': _getAuthorName((i % 10) + 1),
      'authorUsername': '@${_getUsername((i % 10) + 1)}',
      'authorAvatar': 'assets/images/Avatar${((i % 2) + 1)}.png',
      'isAuthorVerified': i % 7 == 0,
      'content': contents[i % contents.length],
      'imageUrls': i % 3 == 0 ? ['assets/images/test.png'] : null,
      'videoUrl': null,
      'gifUrl': null,
      'timestamp': now.subtract(Duration(hours: hoursAgo)).toIso8601String(),
      'type': i % 3 == 0 ? 'image' : 'text',
      'reactionCount': 10 + (i % 100),
      'commentCount': 2 + (i % 30),
      'shareCount': i % 15,
      'viewCount': 50 + (i % 500),
      'hasReacted': false,
      'userReactionType': null,
      'isSaved': false,
      'hashtags': _getHashtags(i),
      'mentions': [],
      'originalPostId': null,
      'location': i % 10 == 0 ? 'Paris, France' : null,
      'commentsEnabled': true,
      'isPinned': i == 0,
      'isArchived': false,
    });
  }

  return posts;
}

List<Map<String, dynamic>> _generateProfiles() {
  final now = DateTime.now();
  final profiles = <Map<String, dynamic>>[];

  final bios = [
    'Développeur Flutter passionné 🚀 | Lead dev chez TableRonde',
    'UI/UX Designer | Créateur d\'expériences digitales 🎨',
    'Backend Developer | Node.js & Firebase expert ☕',
    'Product Manager @ TableRonde | Passionnée par l\'innovation',
    'QA Engineer | Bug hunter 🐛 | Automation enthusiast',
    'Pro Gamer & Streamer 🎮 | FPS specialist',
    'Competitive gamer | Team captain 🥷',
    'Graphic Designer | Illustratrice freelance 🐱',
    'Personal Trainer | Nutrition coach 💪',
    'Photographe professionnelle 📷 | Voyageuse',
  ];

  for (var i = 0; i < 20; i++) {
    profiles.add({
      'id': 'user_${i + 1}',
      'name': _getAuthorName(i + 1),
      'username': '@${_getUsername(i + 1)}',
      'bio': bios[i % bios.length],
      'phone': '+33 6 ${(12 + i).toString().padLeft(2, '0')} 34 56 78',
      'avatarUrl': 'assets/images/Avatar${((i % 2) + 1)}.png',
      'createdAt': now.subtract(Duration(days: 365 - (i * 10))).toIso8601String(),
      'isOnline': i % 3 == 0,
      'currentActivity': i % 3 == 0 ? 'En ligne' : null,
    });
  }

  return profiles;
}

List<Map<String, dynamic>> _generateChats() {
  final now = DateTime.now();
  final chats = <Map<String, dynamic>>[];

  final lastMessages = [
    'Il me dit f*ck you mdr.',
    'Seigneur.💔🙌 !!',
    'N\'oubliez pas de mettre à jour...',
    'Super ! On se voit demain ?',
    'J\'ai terminé la feature 🚀',
    'Merci pour ton aide !',
    'Tu as vu le dernier commit ?',
    'On fait une pause café ? ☕',
  ];

  for (var i = 0; i < 10; i++) {
    chats.add({
      'id': '${i + 1}',
      'name': _getAuthorName(i + 1),
      'lastMessage': lastMessages[i % lastMessages.length],
      'lastMessageTime': now.subtract(Duration(hours: i * 2)).toIso8601String(),
      'avatarUrl': 'assets/images/Avatar${((i % 2) + 1)}.png',
      'isOnline': i % 3 == 0,
      'unreadCount': i % 4,
      'bio': 'Utilisateur de TableRonde',
      'username': '@${_getUsername(i + 1)}',
      'phone': '+33 6 ${(12 + i).toString().padLeft(2, '0')} 34 56 78',
      'createdAt': now.subtract(Duration(days: 100 + i * 10)).toIso8601String(),
      'currentActivity': i % 3 == 0 ? 'En ligne' : 'Vu récemment',
    });
  }

  return chats;
}

List<Map<String, dynamic>> _generateMessages() {
  final now = DateTime.now();
  final messages = <Map<String, dynamic>>[];

  final texts = [
    'Salut ! Comment ça va ? 😊',
    'Ça va super bien ! Et toi ?',
    'Très bien aussi ! Je travaille sur un nouveau projet.',
    'Intéressant ! Tu peux m\'en dire plus ?',
    'C\'est un projet de développement mobile avec Flutter',
    'Excellent choix ! Flutter est vraiment puissant 💪',
    'Tu es disponible pour une réunion demain ?',
    'Oui, à quelle heure ?',
    'Vers 14h ça te va ?',
    'Parfait ! À demain alors 👍',
  ];

  var messageId = 1;
  for (var chatId = 1; chatId <= 10; chatId++) {
    for (var i = 0; i < 10; i++) {
      messages.add({
        'id': 'msg_${messageId++}',
        'chatId': '$chatId',
        'text': texts[i % texts.length],
        'isSentByMe': i % 2 == 0,
        'timestamp': now.subtract(Duration(hours: chatId * 2, minutes: i * 5)).toIso8601String(),
        'isRead': true,
        'type': 'text',
        'attachmentUrl': null,
        'attachmentName': null,
        'stickerUrl': null,
        'gifUrl': null,
        'replyToId': null,
        'voiceDuration': null,
        'isEdited': false,
        'isDeleted': false,
        'reactions': {},
      });
    }
  }

  return messages;
}

List<Map<String, dynamic>> _generateComments() {
  final now = DateTime.now();
  final comments = <Map<String, dynamic>>[];

  final commentTexts = [
    'Super intéressant ! J\'ai hâte de tester ça 🚀',
    'Merci pour le partage !',
    'Excellent article, très instructif 👍',
    'Je suis d\'accord avec toi',
    'Bonne idée ! Je vais essayer',
    'Merci pour ces conseils précieux',
    'C\'est exactement ce que je cherchais !',
    'Bravo pour ce travail 👏',
  ];

  var commentId = 1;
  for (var postId = 1; postId <= 50; postId++) {
    final numComments = (postId % 5) + 1;
    for (var i = 0; i < numComments; i++) {
      comments.add({
        'id': 'comment_$commentId',
        'postId': 'post_$postId',
        'authorId': 'user_${(commentId % 10) + 1}',
        'authorName': _getAuthorName((commentId % 10) + 1),
        'authorUsername': '@${_getUsername((commentId % 10) + 1)}',
        'authorAvatar': 'assets/images/Avatar${((commentId % 2) + 1)}.png',
        'content': commentTexts[commentId % commentTexts.length],
        'timestamp': now.subtract(Duration(hours: postId, minutes: i * 10)).toIso8601String(),
        'likeCount': commentId % 20,
      });
      commentId++;
    }
  }

  return comments;
}

List<Map<String, dynamic>> _generateNotifications() {
  final now = DateTime.now();
  final notifications = <Map<String, dynamic>>[];

  final types = ['like', 'comment', 'follow', 'mention', 'share'];
  final messages = [
    'a aimé votre post',
    'a commenté votre post',
    'a commencé à vous suivre',
    'vous a mentionné dans un post',
    'a partagé votre post',
  ];

  for (var i = 0; i < 30; i++) {
    final typeIndex = i % types.length;
    notifications.add({
      'id': 'notif_${i + 1}',
      'userId': 'user_1',
      'type': types[typeIndex],
      'message': '${_getAuthorName((i % 10) + 1)} ${messages[typeIndex]}',
      'timestamp': now.subtract(Duration(hours: i * 2)).toIso8601String(),
      'isRead': i > 5,
      'relatedId': 'post_${(i % 50) + 1}',
      'actorId': 'user_${(i % 10) + 1}',
      'actorName': _getAuthorName((i % 10) + 1),
      'actorAvatar': 'assets/images/Avatar${((i % 2) + 1)}.png',
    });
  }

  return notifications;
}

String _getAuthorName(int index) {
  final names = [
    'AlistairJr', 'T4zor', 'Tk-Porky', 'Sophie Martin', 'Lucas Dubois',
    'ProGamer42', 'NinjaKiller', 'Emma Leroy', 'MaxPower', 'Julie Bernard',
    'Thomas Petit', 'Camille Roux', 'Hugo Moreau', 'Papa Jean', 'Maman Marie',
    'Julie Med', 'Pierre Eng', 'Mamie Louise', 'Oncle Paul', 'Sarah Chen',
  ];
  return names[(index - 1) % names.length];
}

String _getUsername(int index) {
  final usernames = [
    'alistairjr', 't4zor', 'tkporky', 'sophiemartin', 'lucasdubois',
    'progamer42', 'ninjakiller', 'emmaleroy', 'maxpower', 'juliebernard',
    'thomaspetit', 'camilleroux', 'hugomoreau', 'papajean', 'mamanmarie',
    'juliemed', 'pierreeng', 'mamielouise', 'onclepaul', 'sarahchen',
  ];
  return usernames[(index - 1) % usernames.length];
}

List<String> _getHashtags(int index) {
  final hashtagSets = [
    ['Flutter', 'Dev', 'Mobile'],
    ['Gaming', 'Perseverance'],
    ['CodeLife', 'Programming'],
    ['Tech', 'Architecture'],
    ['SQL', 'Database'],
    ['Gaming', 'Victory'],
    ['Ninja', 'Code'],
    ['SOLID', 'CleanCode'],
    ['Motivation', 'Coding'],
    ['WebAssembly', 'Performance'],
  ];
  return hashtagSets[index % hashtagSets.length];
}
