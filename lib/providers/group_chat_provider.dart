import 'package:flutter/foundation.dart';
import '../models/groups/group_chat_model.dart';
import '../models/groups/group_member_model.dart';
import '../models/groups/group_permission.dart';
import '../models/chat_model.dart';
import '../models/auth/user_model.dart';
import '../services/api_service.dart';
import '../utils/avatar_helper.dart';

/// Provider pour la gestion des groupes de discussion
/// Gère la création, modification et suppression de groupes
class GroupChatProvider extends ChangeNotifier {
  // État privé
  List<GroupChatModel> _groups = [];
  Map<String, List<MessageModel>> _groupMessages = {};
  UserModel? _currentUser; // Utilisateur actuel synchronisé avec AuthProvider
  bool _isLoading = false;
  String? _error;

  /// Constructeur
  GroupChatProvider();

  /// Synchronise avec l'utilisateur authentifié
  void syncWithAuthUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Getters publics
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge tous les groupes depuis l'API
  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await ApiService.getGroups();
      // Trier par timestamp décroissant
      _groups.sort((a, b) => (b.lastMessageTime ?? b.createdAt)
          .compareTo(a.lastMessageTime ?? a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les messages d'un groupe depuis l'API
  Future<void> loadMessages(String groupId) async {
    try {
      final messages = await ApiService.getMessages(groupId);
      _groupMessages[groupId] = messages;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Getters publics

  /// Retourne la liste de tous les groupes
  List<GroupChatModel> get groups => List.unmodifiable(_groups);

  /// Retourne un groupe par son ID
  GroupChatModel? getGroupById(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Retourne les messages d'un groupe
  List<MessageModel> getGroupMessages(String groupId) {
    return List.unmodifiable(_groupMessages[groupId] ?? []);
  }

  /// Retourne l'ID de l'utilisateur actuel
  String get currentUserId => _currentUser?.id ?? 'user_1';

  // Actions publiques

  /// Crée un nouveau groupe avec validation
  ///
  /// Valide que:
  /// - Le nom n'est pas vide
  /// - Le nom ne dépasse pas 50 caractères
  /// - Au moins un membre est sélectionné
  ///
  /// Throws [ArgumentError] si la validation échoue
  Future<GroupChatModel> createGroup({
    required String name,
    String? description,
    String? photoUrl,
    required List<String> memberIds,
  }) async {
    // Validation du nom
    if (name.trim().isEmpty) {
      throw ArgumentError('Le nom du groupe est requis');
    }

    if (name.length > 50) {
      throw ArgumentError(
          'Le nom du groupe est trop long (maximum 50 caractères)');
    }

    // Validation des membres
    if (memberIds.isEmpty) {
      throw ArgumentError('Sélectionnez au moins un membre');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Dédupliquer les IDs de membres
      final uniqueMemberIds = memberIds.toSet().toList();

      // Créer les membres du groupe
      // L'utilisateur actuel est automatiquement admin
      final members = <GroupMemberModel>[];

      // Ajouter l'utilisateur actuel comme admin
      if (!uniqueMemberIds.contains(currentUserId)) {
        members.add(GroupMemberModel(
          userId: currentUserId,
          name: _currentUser?.name ?? 'Moi',
          avatarUrl: _currentUser?.avatarUrl ?? AvatarHelper.getAvatarUrl(currentUserId),
          permission: GroupPermission.admin,
          joinedAt: DateTime.now(),
        ));
      }

      // Ajouter les autres membres
      for (final memberId in uniqueMemberIds) {
        members.add(GroupMemberModel(
          userId: memberId,
          name: 'User $memberId', // Nom mockée
          avatarUrl: AvatarHelper.getAvatarUrl(memberId),
          permission: memberId == currentUserId
              ? GroupPermission.admin
              : GroupPermission.member,
          joinedAt: DateTime.now(),
        ));
      }

      // Créer le nouveau groupe
      final newGroup = GroupChatModel(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        description: description,
        photoUrl: photoUrl,
        members: members,
        createdAt: DateTime.now(),
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
      );

      // Envoyer à l'API
      final savedGroup = await ApiService.createGroup(newGroup);

      // Ajouter le groupe à la liste
      _groups.add(savedGroup);

      // Initialiser la liste de messages vide pour ce groupe
      _groupMessages[savedGroup.id] = [];

      _isLoading = false;
      notifyListeners();

      return savedGroup;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour un groupe
  Future<void> updateGroup(String groupId, GroupChatModel updatedGroup) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedGroup = await ApiService.updateGroup(groupId, updatedGroup);

      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = savedGroup;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Ajoute un membre à un groupe
  ///
  /// Vérifie que l'utilisateur actuel a la permission d'ajouter des membres
  /// (admin ou moderator)
  ///
  /// Throws [StateError] si l'utilisateur n'a pas la permission
  /// Throws [ArgumentError] si le groupe n'existe pas ou le membre est déjà présent
  Future<void> addMember(String groupId, String userId) async {
    final group = getGroupById(groupId);

    if (group == null) {
      throw ArgumentError('Le groupe n\'existe pas');
    }

    // Vérifier les permissions
    if (!group.canUserManageMembers(currentUserId)) {
      throw StateError('Vous n\'avez pas la permission d\'ajouter des membres');
    }

    // Vérifier si le membre existe déjà
    if (group.members.any((member) => member.userId == userId)) {
      throw ArgumentError('Ce membre fait déjà partie du groupe');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Créer le nouveau membre
    final newMember = GroupMemberModel(
      userId: userId,
      name: 'User $userId', // Nom mockée
      avatarUrl: AvatarHelper.getAvatarUrl(userId),
      permission: GroupPermission.member,
      joinedAt: DateTime.now(),
    );

    // Mettre à jour le groupe avec le nouveau membre
    final updatedMembers = List<GroupMemberModel>.from(group.members)
      ..add(newMember);
    final updatedGroup = group.copyWith(members: updatedMembers);

    // Remplacer le groupe dans la liste
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  /// Retire un membre d'un groupe
  ///
  /// Vérifie que l'utilisateur actuel a la permission de retirer des membres
  /// (admin ou moderator)
  ///
  /// Throws [StateError] si l'utilisateur n'a pas la permission
  /// Throws [ArgumentError] si le groupe n'existe pas ou le membre n'est pas présent
  Future<void> removeMember(String groupId, String userId) async {
    final group = getGroupById(groupId);

    if (group == null) {
      throw ArgumentError('Le groupe n\'existe pas');
    }

    // Vérifier les permissions
    if (!group.canUserManageMembers(currentUserId)) {
      throw StateError('Vous n\'avez pas la permission de retirer des membres');
    }

    // Vérifier si le membre existe
    if (!group.members.any((member) => member.userId == userId)) {
      throw ArgumentError('Ce membre ne fait pas partie du groupe');
    }

    // Empêcher de retirer le dernier admin
    final admins = group.admins;
    final memberToRemove = group.members.firstWhere((m) => m.userId == userId);
    if (memberToRemove.permission == GroupPermission.admin &&
        admins.length == 1) {
      throw StateError(
          'Impossible de retirer le dernier administrateur du groupe');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Retirer le membre
    final updatedMembers =
        group.members.where((m) => m.userId != userId).toList();
    final updatedGroup = group.copyWith(members: updatedMembers);

    // Remplacer le groupe dans la liste
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  /// Met à jour la permission d'un membre (admin uniquement)
  ///
  /// Seuls les administrateurs peuvent modifier les permissions
  ///
  /// Throws [StateError] si l'utilisateur n'est pas admin
  /// Throws [ArgumentError] si le groupe ou le membre n'existe pas
  Future<void> updateMemberPermission(
    String groupId,
    String userId,
    GroupPermission permission,
  ) async {
    final group = getGroupById(groupId);

    if (group == null) {
      throw ArgumentError('Le groupe n\'existe pas');
    }

    // Vérifier que l'utilisateur actuel est admin
    if (!group.isUserAdmin(currentUserId)) {
      throw StateError(
          'Seuls les administrateurs peuvent modifier les permissions');
    }

    // Vérifier si le membre existe
    final memberIndex = group.members.indexWhere((m) => m.userId == userId);
    if (memberIndex == -1) {
      throw ArgumentError('Ce membre ne fait pas partie du groupe');
    }

    // Empêcher de retirer le dernier admin
    final currentMember = group.members[memberIndex];
    if (currentMember.permission == GroupPermission.admin &&
        permission != GroupPermission.admin &&
        group.admins.length == 1) {
      throw StateError(
          'Impossible de retirer les permissions du dernier administrateur');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Mettre à jour la permission du membre
    final updatedMembers = List<GroupMemberModel>.from(group.members);
    updatedMembers[memberIndex] =
        currentMember.copyWith(permission: permission);
    final updatedGroup = group.copyWith(members: updatedMembers);

    // Remplacer le groupe dans la liste
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  /// Permet à l'utilisateur actuel de quitter un groupe
  ///
  /// Si l'utilisateur est le dernier admin, une erreur est levée
  ///
  /// Throws [ArgumentError] si le groupe n'existe pas
  /// Throws [StateError] si l'utilisateur est le dernier admin
  Future<void> leaveGroup(String groupId) async {
    final group = getGroupById(groupId);

    if (group == null) {
      throw ArgumentError('Le groupe n\'existe pas');
    }

    // Vérifier si l'utilisateur est membre du groupe
    if (!group.members.any((m) => m.userId == currentUserId)) {
      throw ArgumentError('Vous ne faites pas partie de ce groupe');
    }

    // Empêcher de quitter si c'est le dernier admin
    final currentMember =
        group.members.firstWhere((m) => m.userId == currentUserId);
    if (currentMember.permission == GroupPermission.admin &&
        group.admins.length == 1) {
      throw StateError(
          'Vous êtes le dernier administrateur. Nommez un autre admin avant de quitter.');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Retirer l'utilisateur du groupe
    final updatedMembers =
        group.members.where((m) => m.userId != currentUserId).toList();

    // Si le groupe n'a plus de membres, le supprimer complètement
    if (updatedMembers.isEmpty) {
      _groups.removeWhere((g) => g.id == groupId);
      _groupMessages.remove(groupId);
    } else {
      final updatedGroup = group.copyWith(members: updatedMembers);
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }
    }

    notifyListeners();
  }

  /// Envoie un message dans un groupe avec mise à jour optimiste
  ///
  /// Vérifie que l'utilisateur est membre du groupe
  ///
  /// Throws [ArgumentError] si le groupe n'existe pas
  /// Throws [StateError] si l'utilisateur n'est pas membre
  Future<void> sendMessage(String groupId, MessageModel message) async {
    final group = getGroupById(groupId);

    // Si c'est un groupe, vérifier les permissions
    if (group != null) {
      // Vérifier si l'utilisateur est membre du groupe
      if (!group.members.any((m) => m.userId == currentUserId)) {
        throw StateError('Vous ne faites pas partie de ce groupe');
      }
    }

    // Mise à jour optimiste: ajouter le message localement
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }
    _groupMessages[groupId]!.add(message);

    // Mettre à jour le dernier message du groupe localement (si c'est un groupe)
    if (group != null) {
      final updatedGroup = group.copyWith(
        lastMessage: message.text.isNotEmpty ? message.text : 'Média partagé',
        lastMessageTime: message.timestamp,
      );

      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }
    }
    notifyListeners();

    try {
      // Envoyer à l'API
      final confirmedMessage = await ApiService.sendMessage(message);

      // Remplacer le message temporaire par le message confirmé
      final messages = _groupMessages[groupId]!;
      final msgIndex = messages.indexWhere((m) => m.id == message.id);
      if (msgIndex != -1) {
        messages[msgIndex] = confirmedMessage;
        notifyListeners();
      }
    } catch (e) {
      // Rollback en cas d'échec
      _groupMessages[groupId]!.removeWhere((m) => m.id == message.id);

      // Restaurer l'ancien dernier message (si c'est un groupe)
      if (group != null) {
        final index = _groups.indexWhere((g) => g.id == groupId);
        if (_groupMessages[groupId]!.isNotEmpty) {
          final lastMsg = _groupMessages[groupId]!.last;
          final restoredGroup = group.copyWith(
            lastMessage:
                lastMsg.text.isNotEmpty ? lastMsg.text : 'Média partagé',
            lastMessageTime: lastMsg.timestamp,
          );
          if (index != -1) {
            _groups[index] = restoredGroup;
          }
        } else {
          // Pas de messages, restaurer à null
          final restoredGroup = group.copyWith(
            lastMessage: null,
            lastMessageTime: null,
          );
          if (index != -1) {
            _groups[index] = restoredGroup;
          }
        }
      }

      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Réinitialise le provider
  /// Utile pour les tests
  void reset() {
    _groups = [];
    _groupMessages = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
