﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Выводит запрос на отправку дампов.
//
Процедура ЦентрМониторингаЗапросНаОтправкуДампов() Экспорт
	ЦентрМониторингаКлиентСлужебный.ОповеститьЗапросНаОтправкуДампов();
КонецПроцедуры

// Выводит запрос на сбор и отправку дампов (один раз).
//
Процедура ЦентрМониторингаЗапросНаСборИОтправкуДампов() Экспорт
	ЦентрМониторингаКлиентСлужебный.ОповеститьЗапросНаПолучениеДампов();
КонецПроцедуры

// Выводит запрос на получение контактной информации администратора.
//
Процедура ЦентрМониторингаЗапросКонтактнойИнформации() Экспорт
	ЦентрМониторингаКлиентСлужебный.ОповеститьЗапросКонтактнойИнформации();
КонецПроцедуры

#КонецОбласти
