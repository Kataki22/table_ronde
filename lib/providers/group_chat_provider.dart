import 'package:flutter/foundation.dart';
import '../models/groups/group_chat_model.dart';
import '../models/groups/group_member_model.dart';
import '../models/groups/group_permission.dart';
import '../models/chat_model.dart';
import '../data/mock_groups_data.dart';

/// Provider pour la gestion des groupes de discussion
/// Gère la création, modification et suppression de groupes
class GroupChatProvider extends ChangeNotifier {
  // État privé
  List<GroupChatModel> _groups = [];
  Map<String, List<MessageModel>> _groupMessages = {};
  final String _currentUserId = 'user_1'; // ID de l'utilisateur actuel (mockée)

  /// Constructeur - charge les données mockées
  GroupChatProvider() {
    _loadMockData();
  }

  /// Charge les données mockées depuis MockGroupsData
  void _loadMockData() {
    _groups = List.from(MockGroupsData.groups);
    _groupMessages = Map.from(MockGroupsData.groupMessages);
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
  String get currentUserId => _currentUserId;

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
      throw ArgumentError('Le nom du groupe est trop long (maximum 50 caractères)');
    }

    // Validation des membres
    if (memberIds.isEmpty) {
      throw ArgumentError('Sélectionnez au moins un membre');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 200));

    // Dédupliquer les IDs de membres
    final uniqueMemberIds = memberIds.toSet().toList();

    // Créer les membres du groupe
    // L'utilisateur actuel est automatiquement admin
    final members = <GroupMemberModel>[];
    
    // Ajouter l'utilisateur actuel comme admin
    if (!uniqueMemberIds.contains(_currentUserId)) {
      members.add(GroupMemberModel(
        userId: _currentUserId,
        name: 'Moi', // Nom mockée
        avatarUrl: 'assets/images/Avatar1.png',
        permission: GroupPermission.admin,
        joinedAt: DateTime.now(),
      ));
    }

    // Ajouter les autres membres
    for (final memberId in uniqueMemberIds) {
      members.add(GroupMemberModel(
        userId: memberId,
        name: 'User $memberId', // Nom mockée
        avatarUrl: 'assets/images/Avatar${(members.length + 1) % 10}.png',
        permission: memberId == _currentUserId 
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

    // Ajouter le groupe à la liste
    _groups.add(newGroup);
    
    // Initialiser la liste de messages vide pour ce groupe
    _groupMessages[newGroup.id] = [];

    // Notifier les listeners
    notifyListeners();

    return newGroup;
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
    if (!group.canUserManageMembers(_currentUserId)) {
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
      avatarUrl: 'assets/images/Avatar${(group.members.length + 1) % 10}.png',
      permission: GroupPermission.member,
      joinedAt: DateTime.now(),
    );

    // Mettre à jour le groupe avec le nouveau membre
    final updatedMembers = List<GroupMemberModel>.from(group.members)..add(newMember);
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
    if (!group.canUserManageMembers(_currentUserId)) {
      throw StateError('Vous n\'avez pas la permission de retirer des membres');
    }

    // Vérifier si le membre existe
    if (!group.members.any((member) => member.userId == userId)) {
      throw ArgumentError('Ce membre ne fait pas partie du groupe');
    }

    // Empêcher de retirer le dernier admin
    final admins = group.admins;
    final memberToRemove = group.members.firstWhere((m) => m.userId == userId);
    if (memberToRemove.permission == GroupPermission.admin && admins.length == 1) {
      throw StateError('Impossible de retirer le dernier administrateur du groupe');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Retirer le membre
    final updatedMembers = group.members.where((m) => m.userId != userId).toList();
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
    if (!group.isUserAdmin(_currentUserId)) {
      throw StateError('Seuls les administrateurs peuvent modifier les permissions');
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
      throw StateError('Impossible de retirer les permissions du dernier administrateur');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Mettre à jour la permission du membre
    final updatedMembers = List<GroupMemberModel>.from(group.members);
    updatedMembers[memberIndex] = currentMember.copyWith(permission: permission);
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
    if (!group.members.any((m) => m.userId == _currentUserId)) {
      throw ArgumentError('Vous ne faites pas partie de ce groupe');
    }

    // Empêcher de quitter si c'est le dernier admin
    final currentMember = group.members.firstWhere((m) => m.userId == _currentUserId);
    if (currentMember.permission == GroupPermission.admin && group.admins.length == 1) {
      throw StateError('Vous êtes le dernier administrateur. Nommez un autre admin avant de quitter.');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    // Retirer l'utilisateur du groupe
    final updatedMembers = group.members.where((m) => m.userId != _currentUserId).toList();
    
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

  /// Envoie un message dans un groupe
  /// 
  /// Vérifie que l'utilisateur est membre du groupe
  /// 
  /// Throws [ArgumentError] si le groupe n'existe pas
  /// Throws [StateError] si l'utilisateur n'est pas membre
  Future<void> sendGroupMessage(String groupId, MessageModel message) async {
    final group = getGroupById(groupId);
    
    if (group == null) {
      throw ArgumentError('Le groupe n\'existe pas');
    }

    // Vérifier si l'utilisateur est membre du groupe
    if (!group.members.any((m) => m.userId == _currentUserId)) {
      throw StateError('Vous ne faites pas partie de ce groupe');
    }

    // Simulation de latence réseau
    await Future.delayed(const Duration(milliseconds: 100));

    // Ajouter le message à la liste des messages du groupe
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }
    _groupMessages[groupId]!.add(message);

    // Mettre à jour le dernier message du groupe
    final updatedGroup = group.copyWith(
      lastMessage: message.text.isNotEmpty ? message.text : 'Média partagé',
      lastMessageTime: message.timestamp,
    );

    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  /// Réinitialise le provider avec les données mockées
  /// Utile pour les tests
  void reset() {
    _loadMockData();
    notifyListeners();
  }
}
