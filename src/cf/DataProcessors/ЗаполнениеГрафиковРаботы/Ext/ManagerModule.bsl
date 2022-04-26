﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.НачальноеЗаполнение = Истина;
	Обработчик.Версия = "1.0.0.2";
	Обработчик.Процедура = "Обработки.ЗаполнениеГрафиковРаботы.СоздатьКалендарьПятидневкаРоссийскойФедерации";
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

// Создает график работы на основе производственного календаря Российской Федерации по шаблону "Пятидневка".
//
Процедура СоздатьКалендарьПятидневкаРоссийскойФедерации() Экспорт
	
	ПроизводственныйКалендарь = КалендарныеГрафики.ОсновнойПроизводственныйКалендарь();
	Если ПроизводственныйКалендарь = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не Справочники.Календари.НайтиПоРеквизиту("ПроизводственныйКалендарь", ПроизводственныйКалендарь).Пустая() Тогда
		Возврат;
	КонецЕсли;
	
	НовыйГрафикРаботы = Справочники.Календари.СоздатьЭлемент();
	НовыйГрафикРаботы.Наименование = Строка(ПроизводственныйКалендарь);
	НовыйГрафикРаботы.ПроизводственныйКалендарь = ПроизводственныйКалендарь;
	НовыйГрафикРаботы.СпособЗаполнения = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоНеделям;
	НовыйГрафикРаботы.ДатаНачала = НачалоГода(ТекущаяДатаСеанса());
	НовыйГрафикРаботы.УчитыватьПраздники = Истина;
	
	// Заполняем недельный цикл как пятидневку.
	Для НомерДня = 1 По 7 Цикл
		НовыйГрафикРаботы.ШаблонЗаполнения.Добавить().ДеньВключенВГрафик = НомерДня <= 5;
	КонецЦикла;
	
	ОбновлениеИнформационнойБазы.ЗаписатьДанные(НовыйГрафикРаботы, Истина, Истина);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли