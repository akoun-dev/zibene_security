import 'package:flutter/material.dart';
import '../services/auth_persistence_manager.dart';
import '../utils/theme.dart';

class PersistenceSelector extends StatefulWidget {
  final TypePersistance? selectedType;
  final Function(TypePersistance)? onChanged;
  final bool showLabel;
  final bool compact;

  const PersistenceSelector({
    super.key,
    this.selectedType,
    this.onChanged,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  State<PersistenceSelector> createState() => _PersistenceSelectorState();
}

class _PersistenceSelectorState extends State<PersistenceSelector> {
  TypePersistance? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType ?? TypePersistance.local;
  }

  @override
  void didUpdateWidget(PersistenceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedType != oldWidget.selectedType) {
      setState(() {
        _selectedType = widget.selectedType;
      });
    }
  }

  void _onTypeSelected(TypePersistance type) {
    setState(() {
      _selectedType = type;
    });
    widget.onChanged?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Persistance de la session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ...TypePersistance.values.map((type) => _buildOption(type)),
      ],
    );
  }

  Widget _buildCompactView() {
    return Row(
      children: TypePersistance.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => _onTypeSelected(type),
            child: Container(
              margin: EdgeInsets.only(
                right: type != TypePersistance.none ? 4.0 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow.withValues(alpha:0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isSelected ? AppColors.yellow : AppColors.mediumGray,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getIcon(type),
                    size: 20,
                    color: isSelected ? AppColors.yellow : AppColors.mediumGray,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getShortName(type),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.yellow : AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOption(TypePersistance type) {
    final isSelected = _selectedType == type;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _onTypeSelected(type),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.yellow.withValues(alpha:0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected ? AppColors.yellow : AppColors.mediumGray,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(type),
                size: 20,
                color: isSelected ? AppColors.yellow : AppColors.mediumGray,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getName(type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.yellow : Colors.white,
                      ),
                    ),
                    if (!widget.compact)
                      Text(
                        _getDescription(type),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Radio<TypePersistance>(
                value: type,
                groupValue: _selectedType,
                onChanged: (value) => _onTypeSelected(type),
                activeColor: AppColors.yellow,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return Icons.storage;
      case TypePersistance.session:
        return Icons.tab;
      case TypePersistance.none:
        return Icons.memory;
    }
  }

  String _getName(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'Locale (persistante)';
      case TypePersistance.session:
        return 'Session (onglet)';
      case TypePersistance.none:
        return 'Aucune (mémoire)';
    }
  }

  String _getShortName(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'Locale';
      case TypePersistance.session:
        return 'Session';
      case TypePersistance.none:
        return 'Aucune';
    }
  }

  String _getDescription(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'Reste connecté même après fermeture';
      case TypePersistance.session:
        return 'Session active uniquement';
      case TypePersistance.none:
        return 'Reconnexion à chaque fois';
    }
  }
}

/// Widget pour afficher l'état de persistance actuel
class PersistenceStatusIndicator extends StatelessWidget {
  final TypePersistance? type;
  final bool? isValid;
  final bool? isConnected;

  const PersistenceStatusIndicator({
    super.key,
    this.type,
    this.isValid,
    this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 14,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4.0),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isConnected == false) {
      return AppColors.danger;
    }
    if (isValid == false) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (isConnected == false) {
      return Icons.offline_bolt;
    }
    if (isValid == false) {
      return Icons.warning;
    }
    return Icons.check_circle;
  }

  String _getStatusText() {
    if (type == null) {
      return 'Non défini';
    }
    if (isConnected == false) {
      return 'Hors ligne';
    }
    if (isValid == false) {
      return 'Expirée';
    }
    return _getTypeName(type!);
  }

  String _getTypeName(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'Locale';
      case TypePersistance.session:
        return 'Session';
      case TypePersistance.none:
        return 'Mémoire';
    }
  }
}