﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	Если Значение = Перечисления.ТипыПодписиКриптографии.ОбычнаяCMS
		Или Значение = Перечисления.ТипыПодписиКриптографии.БазоваяCAdESBES
		Или Не ЗначениеЗаполнено(Значение) Тогда
		Если Константы.УсовершенствоватьПодписиАвтоматически.Получить() <> 0 Тогда
			Константы.УсовершенствоватьПодписиАвтоматически.Установить(0);
		КонецЕсли;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.ИзменитьРегламентноеЗаданиеПродлениеДостоверностиПодписей(,,Значение);

КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли