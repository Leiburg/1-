﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	СписокЗначений = Новый СписокЗначений;
	СписокЗначений.Добавить(Перечисления.ТипыПодписиКриптографии.CAdESBES);
	СписокЗначений.Добавить(Перечисления.ТипыПодписиКриптографии.CAdEST);
	СписокЗначений.Добавить(Перечисления.ТипыПодписиКриптографии.CAdESAv3);
	
	ДанныеВыбора = СписокЗначений;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли