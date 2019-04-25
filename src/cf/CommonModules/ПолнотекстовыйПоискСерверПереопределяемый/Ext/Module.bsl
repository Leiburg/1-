﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Позволяет внести изменения в дерево с разделами полнотекстового поиска, отображаемое при выборе области поиска.
// По умолчанию дерево разделов формируется на основании состава подсистем конфигурации.
// Структура дерева описана в форме Обработка.ПолнотекстовыйПоискВДанных.Форма.ВыборОбластиПоиска.
// Все колонки, не указанные в параметрах, будут автоматически рассчитаны.
// При необходимости построить дерево разделов самостоятельно требуется сохранить состав колонок.
//
// Параметры:
//   РазделыПоиска - ДеревоЗначений - области поиска. Содержит колонки:
//       ** Раздел   - Строка   - представление раздела: подсистемы или объекта метаданных.
//       ** Картинка - Картинка - картинка раздела, рекомендуется только для корневых разделов.
//       ** ОбъектМД - СправочникСсылка.ИдентификаторыОбъектовМетаданных - задается только для объектов метаданных,
//                     для разделов остается пустым.
// Пример:
//
//	НовыйРаздел = РазделыПоиска.Строки.Добавить();
//	НовыйРаздел.Раздел = "Главное";
//	НовыйРаздел.Картинка = БиблиотекаКартинок._ДемоРазделГлавное;
//	
//	ОбъектМетаданных = Метаданные.Документы._ДемоСчетНаОплатуПокупателю;
//	
//	Если ПравоДоступа("Просмотр", ОбъектМетаданных)
//		И ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ОбъектМетаданных) Тогда 
//		
//		НовыйОбъектРаздела = НовыйРаздел.Строки.Добавить();
//		НовыйОбъектРаздела.Раздел = ОбъектМетаданных.ПредставлениеСписка;
//		НовыйОбъектРаздела.ОбъектМД = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ОбъектМетаданных);
//	КонецЕсли;
//
Процедура ПриПолученииРазделовПолнотекстовогоПоиска(РазделыПоиска) Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти