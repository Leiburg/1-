﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ДлительнаяОперацияСклоненияПоПадежам(
	ИдентификаторФормы, Представление, ПараметрыСклонения, ПоказыватьСообщения = Ложь) Экспорт
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(ИдентификаторФормы);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Склонение'");
	
	Возврат ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, 
		"СклонениеПредставленийОбъектов.ДанныеСклонения", Представление, ПараметрыСклонения, ПоказыватьСообщения);
	
КонецФункции

Функция ЕстьПравоДоступаКОбъекту(Ссылка) Экспорт
	Возврат СклонениеПредставленийОбъектов.ЕстьПравоДоступаКОбъекту(Ссылка);
КонецФункции

#КонецОбласти