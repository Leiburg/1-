﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	// Исправить включение в график рабочих и предпраздничных дней, выпадающих на субботу и воскресенье.
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДниГрафика.Календарь КАК Календарь,
		|	ДниГрафика.Год КАК Год
		|ИЗ
		|	РегистрСведений.КалендарныеГрафики КАК ДниГрафика
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Календари КАК ГрафикиРаботы
		|		ПО (ГрафикиРаботы.Ссылка = ДниГрафика.Календарь)
		|			И (ГрафикиРаботы.СпособЗаполнения = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияГрафикаРаботы.ПоНеделям))
		|			И (ГрафикиРаботы.УчитыватьПраздники)
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДанныеПроизводственногоКалендаря КАК ДанныеКалендаря
		|		ПО (ГрафикиРаботы.ПроизводственныйКалендарь = ДанныеКалендаря.ПроизводственныйКалендарь)
		|			И ДниГрафика.Год = ДанныеКалендаря.Год
		|			И ДниГрафика.ДатаГрафика = ДанныеКалендаря.Дата
		|			И (НЕ ДниГрафика.ДеньВключенВГрафик)
		|			И (ДЕНЬНЕДЕЛИ(ДанныеКалендаря.Дата) В (6, 7))
		|			И (ДанныеКалендаря.ВидДня В (ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Рабочий), ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Предпраздничный)))
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РучныеИзмененияГрафиковРаботы КАК РучныеИзменения
		|		ПО (РучныеИзменения.ГрафикРаботы = ДниГрафика.Календарь)
		|			И (РучныеИзменения.Год = ДниГрафика.Год)
		|			И (РучныеИзменения.ДатаГрафика = ДниГрафика.ДатаГрафика)
		|ГДЕ
		|	ЕСТЬNULL(РучныеИзменения.РучноеИзменение, ЛОЖЬ) = ЛОЖЬ
		|
		|УПОРЯДОЧИТЬ ПО
		|	Календарь,
		|	Год";
	
	ДополнительныеПараметры = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки();
	ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений = Истина;
	ДополнительныеПараметры.ПолноеИмяРегистра = Метаданные.РегистрыСведений.КалендарныеГрафики.ПолноеИмя();
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, Запрос.Выполнить().Выгрузить(), ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ОбработкаЗавершена = Истина;
	
	МетаданныеРегистра    = Метаданные.РегистрыСведений.КалендарныеГрафики;
	ПолноеИмяРегистра     = МетаданныеРегистра.ПолноеИмя();
	ПредставлениеРегистра = МетаданныеРегистра.Представление();
	ПредставлениеОтбора   = НСтр("ru = 'Календарь = ""%1""'");
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьИзмеренияНезависимогоРегистраСведенийДляОбработки(Параметры.Очередь, ПолноеИмяРегистра);
	
	ГрафикиМассив = Новый Массив;
	Пока Выборка.Следующий() Цикл
		ГрафикиМассив.Добавить(Выборка.Календарь);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ГрафикиМассив", ГрафикиМассив);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Календари.Ссылка КАК Ссылка,
		|	Календари.ПроизводственныйКалендарь КАК ПроизводственныйКалендарь,
		|	Календари.СпособЗаполнения КАК СпособЗаполнения,
		|	Календари.ДатаОтсчета КАК ДатаОтсчета,
		|	Календари.УчитыватьПраздники КАК УчитыватьПраздники,
		|	Календари.УчитыватьНерабочиеПериоды КАК УчитыватьНерабочиеПериоды,
		|	Календари.ШаблонЗаполнения.(
		|		Ссылка КАК Ссылка,
		|		НомерСтроки КАК НомерСтроки,
		|		ДеньВключенВГрафик КАК ДеньВключенВГрафик) КАК ШаблонЗаполнения
		|ИЗ
		|	Справочник.Календари КАК Календари
		|ГДЕ
		|	Календари.Ссылка В (&ГрафикиМассив)";
	РеквизитыГрафиков = Запрос.Выполнить().Выгрузить();
	
	РеквизитыГрафиков.Индексы.Добавить("Ссылка");
	ОтборСтрок = Новый Структура("Ссылка");
	
	Обработано = 0;
	Проблемных = 0;
	
	Выборка.Сбросить();
	Пока Выборка.Следующий() Цикл
		ОтборСтрок.Ссылка = Выборка.Календарь;
		РеквизитыГрафика = РеквизитыГрафиков.НайтиСтроки(ОтборСтрок)[0];
		Попытка
			ЗаполнитьГрафикРаботыНаГод(Выборка.Календарь, Выборка.Год, РеквизитыГрафика);
			Обработано = Обработано + 1;
		Исключение
			Проблемных = Проблемных + 1;
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать набор записей регистра ""%1"" с отбором %2 по причине:
                      |%3'"), 
				ПредставлениеРегистра, 
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					ПредставлениеОтбора, 
					Выборка.Календарь),
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(
				ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), 
				УровеньЖурналаРегистрации.Предупреждение,
				МетаданныеРегистра, , 
				ТекстСообщения);
		КонецПопытки;
	КонецЦикла;
	
	Если Не ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, ПолноеИмяРегистра) Тогда
		ОбработкаЗавершена = Ложь;
	КонецЕсли;
	
	ИмяПроцедуры = "РегистрСведений.КалендарныеГрафики.ОбработатьДанныеДляПереходаНаНовуюВерсию";
	
	Если Обработано = 0 И Проблемных <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре %1 не удалось обработать некоторые записи (пропущены): %2'"), 
			ИмяПроцедуры,
			Проблемных);
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;
	
	ЗаписьЖурналаРегистрации(
		ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), 
		УровеньЖурналаРегистрации.Информация, , ,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедура %1 обработала очередную порцию записей: %2'"),
			ИмяПроцедуры,
			Обработано));
	Параметры.ОбработкаЗавершена = ОбработкаЗавершена;
	
КонецПроцедуры

Процедура ЗаполнитьГрафикРаботыНаГод(ГрафикРаботы, Год, РеквизитыГрафика)
	
	НачалоГода = Дата(Год, 1, 1);
	КонецГода = Дата(Год, 12, 31);
	
	РеквизитыГрафика.ШаблонЗаполнения.Сортировать("НомерСтроки");

	ПараметрыЗаполнения = РегистрыСведений.КалендарныеГрафики.ПараметрыЗаполненияГрафика();
	ПараметрыЗаполнения.СпособЗаполнения = РеквизитыГрафика.СпособЗаполнения;
	ПараметрыЗаполнения.ШаблонЗаполнения = РеквизитыГрафика.ШаблонЗаполнения;
	ПараметрыЗаполнения.ПроизводственныйКалендарь = РеквизитыГрафика.ПроизводственныйКалендарь;
	ПараметрыЗаполнения.УчитыватьПраздники = РеквизитыГрафика.УчитыватьПраздники;
	ПараметрыЗаполнения.УчитыватьНерабочиеПериоды = РеквизитыГрафика.УчитыватьНерабочиеПериоды;
	ПараметрыЗаполнения.ДатаОтсчета = РеквизитыГрафика.ДатаОтсчета;
	ДниВключенныеВГрафик = РегистрыСведений.КалендарныеГрафики.ДниВключенныеВГрафик(
		НачалоГода, КонецГода, ПараметрыЗаполнения);
							
	ЗаписатьДанныеГрафикаВРегистр(ГрафикРаботы, ДниВключенныеВГрафик, НачалоГода, КонецГода);
	
КонецПроцедуры

// Выполняет обновление графиков работы по данным производственных календарей, 
// на основании которых они заполняются.
//
// Параметры:
//	- УсловияОбновления - таблица значений с колонками.
//		- КодПроизводственногоКалендаря - код производственного календаря, данные которого изменились,
//		- Год - год, за который нужно обновить данные.
//
Процедура ОбновитьГрафикиРаботыПоДаннымПроизводственныхКалендарей(УсловияОбновления) Экспорт
	
	// Выявим графики, которые нужно обновить
	// получаем данные этих графиков
	// последовательно обновляем за каждый год.
	
	ТекстЗапроса = 
		"ВЫБРАТЬ
		|	УсловияОбновления.КодПроизводственногоКалендаря,
		|	УсловияОбновления.Год,
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(1, 1, 1), ГОД, УсловияОбновления.Год - 1) КАК НачалоГода,
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(1, 12, 31), ГОД, УсловияОбновления.Год - 1) КАК КонецГода
		|ПОМЕСТИТЬ УсловияОбновления
		|ИЗ
		|	&УсловияОбновления КАК УсловияОбновления
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Календари.Ссылка КАК ГрафикРаботы,
		|	Календари.ПроизводственныйКалендарь,
		|	Календари.ДатаНачала,
		|	Календари.ДатаОкончания
		|ПОМЕСТИТЬ ВТГрафикиРаботыЗависимыеОтКалендарей
		|ИЗ
		|	Справочник.Календари КАК Календари
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПроизводственныеКалендари КАК ПроизводственныеКалендари
		|		ПО (ПроизводственныеКалендари.Ссылка = Календари.ПроизводственныйКалендарь)
		|		И (Календари.СпособЗаполнения = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияГрафикаРаботы.ПоНеделям))
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Календари.Ссылка,
		|	Календари.ПроизводственныйКалендарь,
		|	Календари.ДатаНачала,
		|	Календари.ДатаОкончания
		|ИЗ
		|	Справочник.Календари КАК Календари
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПроизводственныеКалендари КАК ПроизводственныеКалендари
		|		ПО (ПроизводственныеКалендари.Ссылка = Календари.ПроизводственныйКалендарь)
		|		И (Календари.СпособЗаполнения = ЗНАЧЕНИЕ(Перечисление.СпособыЗаполненияГрафикаРаботы.ПоЦикламПроизвольнойДлины))
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Календари.ГрафикРаботы,
		|	УсловияОбновления.Год,
		|	ВЫБОР
		|		КОГДА Календари.ДатаНачала < УсловияОбновления.НачалоГода
		|			ТОГДА УсловияОбновления.НачалоГода
		|		ИНАЧЕ Календари.ДатаНачала
		|	КОНЕЦ КАК ДатаНачала,
		|	ВЫБОР
		|		КОГДА Календари.ДатаОкончания > УсловияОбновления.КонецГода
		|			ТОГДА УсловияОбновления.КонецГода
		|		ИНАЧЕ Календари.ДатаОкончания
		|	КОНЕЦ КАК ДатаОкончания
		|ПОМЕСТИТЬ ВТГрафикиРаботыПоУсловиюОбновления
		|ИЗ
		|	ВТГрафикиРаботыЗависимыеОтКалендарей КАК Календари
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ УсловияОбновления КАК УсловияОбновления
		|		ПО (УсловияОбновления.КодПроизводственногоКалендаря = Календари.ПроизводственныйКалендарь.Код)
		|		И Календари.ДатаНачала <= УсловияОбновления.КонецГода
		|		И Календари.ДатаОкончания >= УсловияОбновления.НачалоГода
		|		И (Календари.ДатаОкончания <> ДАТАВРЕМЯ(1, 1, 1))
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Календари.ГрафикРаботы,
		|	УсловияОбновления.Год,
		|	ВЫБОР
		|		КОГДА Календари.ДатаНачала < УсловияОбновления.НачалоГода
		|			ТОГДА УсловияОбновления.НачалоГода
		|		ИНАЧЕ Календари.ДатаНачала
		|	КОНЕЦ,
		|	УсловияОбновления.КонецГода
		|ИЗ
		|	ВТГрафикиРаботыЗависимыеОтКалендарей КАК Календари
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ УсловияОбновления КАК УсловияОбновления
		|		ПО (УсловияОбновления.КодПроизводственногоКалендаря = Календари.ПроизводственныйКалендарь.Код)
		|		И Календари.ДатаНачала <= УсловияОбновления.КонецГода
		|		И (Календари.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1))
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Календари.ГрафикРаботы,
		|	Календари.Год,
		|	Календари.ДатаНачала,
		|	Календари.ДатаОкончания
		|ПОМЕСТИТЬ ВТОбновляемыеГрафикиРаботы
		|ИЗ
		|	ВТГрафикиРаботыПоУсловиюОбновления КАК Календари
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РучныеИзмененияГрафиковРаботы КАК РучныеИзмененияПоВсемГодам
		|		ПО (РучныеИзмененияПоВсемГодам.ГрафикРаботы = Календари.ГрафикРаботы)
		|		И (РучныеИзмененияПоВсемГодам.Год = 0)
		|ГДЕ
		|	РучныеИзмененияПоВсемГодам.ГрафикРаботы ЕСТЬ NULL
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ОбновляемыеГрафикиРаботы.ГрафикРаботы,
		|	ОбновляемыеГрафикиРаботы.Год,
		|	ПараметрыЗаполнения.СпособЗаполнения,
		|	ПараметрыЗаполнения.ПроизводственныйКалендарь,
		|	ОбновляемыеГрафикиРаботы.ДатаНачала,
		|	ОбновляемыеГрафикиРаботы.ДатаОкончания,
		|	ПараметрыЗаполнения.ДатаОтсчета,
		|	ПараметрыЗаполнения.УчитыватьПраздники,
		|	ПараметрыЗаполнения.УчитыватьНерабочиеПериоды
		|ИЗ
		|	ВТОбновляемыеГрафикиРаботы КАК ОбновляемыеГрафикиРаботы
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Календари ПараметрыЗаполнения
		|		ПО ПараметрыЗаполнения.Ссылка = ОбновляемыеГрафикиРаботы.ГрафикРаботы
		|УПОРЯДОЧИТЬ ПО
		|	ОбновляемыеГрафикиРаботы.ГрафикРаботы,
		|	ОбновляемыеГрафикиРаботы.Год
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ШаблонЗаполнения.Ссылка КАК ГрафикРаботы,
		|	ШаблонЗаполнения.НомерСтроки КАК НомерСтроки,
		|	ШаблонЗаполнения.ДеньВключенВГрафик
		|ИЗ
		|	Справочник.Календари.ШаблонЗаполнения КАК ШаблонЗаполнения
		|ГДЕ
		|	ШаблонЗаполнения.Ссылка В
		|		(ВЫБРАТЬ
		|			ВТОбновляемыеГрафикиРаботы.ГрафикРаботы
		|		ИЗ
		|			ВТОбновляемыеГрафикиРаботы)
		|УПОРЯДОЧИТЬ ПО
		|	ГрафикРаботы,
		|	НомерСтроки";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("УсловияОбновления", УсловияОбновления);
	
	РезультатыЗапроса = Запрос.ВыполнитьПакет(); // Массив Из РезультатЗапроса
	ВыборкаПоГрафикам = РезультатыЗапроса[РезультатыЗапроса.ВГраница() - 1].Выбрать();
	ВыборкаПоШаблону = РезультатыЗапроса[РезультатыЗапроса.ВГраница()].Выбрать();
	
	ШаблонЗаполнения = Новый ТаблицаЗначений;
	ШаблонЗаполнения.Колонки.Добавить("ДеньВключенВГрафик", Новый ОписаниеТипов("Булево"));
	
	Пока ВыборкаПоГрафикам.СледующийПоЗначениюПоля("ГрафикРаботы") Цикл
		ШаблонЗаполнения.Очистить();
		Пока ВыборкаПоШаблону.НайтиСледующий(ВыборкаПоГрафикам.ГрафикРаботы, "ГрафикРаботы") Цикл
			НоваяСтрока = ШаблонЗаполнения.Добавить();
			НоваяСтрока.ДеньВключенВГрафик = ВыборкаПоШаблону.ДеньВключенВГрафик;
		КонецЦикла;
		Пока ВыборкаПоГрафикам.СледующийПоЗначениюПоля("ДатаНачала") Цикл
			// Если дата окончания не указана, она будет подобрана по производственному календарю.
			ПараметрыЗаполнения = РегистрыСведений.КалендарныеГрафики.ПараметрыЗаполненияГрафика();
			ПараметрыЗаполнения.СпособЗаполнения = ВыборкаПоГрафикам.СпособЗаполнения;
			ПараметрыЗаполнения.ШаблонЗаполнения = ШаблонЗаполнения;
			ПараметрыЗаполнения.ПроизводственныйКалендарь = ВыборкаПоГрафикам.ПроизводственныйКалендарь;
			ПараметрыЗаполнения.УчитыватьПраздники = ВыборкаПоГрафикам.УчитыватьПраздники;
			ПараметрыЗаполнения.УчитыватьНерабочиеПериоды = ВыборкаПоГрафикам.УчитыватьНерабочиеПериоды;
			ПараметрыЗаполнения.ДатаОтсчета = ВыборкаПоГрафикам.ДатаОтсчета;
			ДниВключенныеВГрафик = РегистрыСведений.КалендарныеГрафики.ДниВключенныеВГрафик(
				ВыборкаПоГрафикам.ДатаНачала, ВыборкаПоГрафикам.ДатаОкончания, ПараметрыЗаполнения);
			ЗаписатьДанныеГрафикаВРегистр(
				ВыборкаПоГрафикам.ГрафикРаботы, ДниВключенныеВГрафик, ВыборкаПоГрафикам.ДатаНачала, ВыборкаПоГрафикам.ДатаОкончания);
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

// Функция читает данные графика работы из регистра.
//
// Параметры:
//	ГрафикРаботы	- ссылка на текущий элемент справочника.
//	НомерГода		- номер года, за который необходимо прочитать график.
//
// Возвращаемое значение - соответствие - где Ключ - дата.
//
Функция ПрочитатьДанныеГрафикаИзРегистра(ГрафикРаботы, НомерГода) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	КалендарныеГрафики.ДатаГрафика КАК ДатаКалендаря
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &ГрафикРаботы
	|	И КалендарныеГрафики.Год = &ТекущийГод
	|	И КалендарныеГрафики.ДеньВключенВГрафик
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаКалендаря";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ГрафикРаботы",	ГрафикРаботы);
	Запрос.УстановитьПараметр("ТекущийГод",		НомерГода);
	
	ДниВключенныеВГрафик = Новый Соответствие;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ДниВключенныеВГрафик.Вставить(Выборка.ДатаКалендаря, Истина);
	КонецЦикла;
	
	Возврат ДниВключенныеВГрафик;
	
КонецФункции

// Процедура записывает данные графика в регистр.
//
// Параметры:
//	ГрафикРаботы	- ссылка на текущий элемент справочника.
//	НомерГода		- номер года, за который необходимо записать график.
//	ДниВключенныеВГрафик - соответствие даты и данных к ней относящихся.
//
// Возвращаемое значение
//	Нет
//
Процедура ЗаписатьДанныеГрафикаВРегистр(ГрафикРаботы, ДниВключенныеВГрафик, ДатаНачала, ДатаОкончания, 
	ЗамещатьРучныеИзменения = Ложь) Экспорт
	
	НаборДни = РегистрыСведений.КалендарныеГрафики.СоздатьНаборЗаписей();
	НаборДни.Отбор.Календарь.Установить(ГрафикРаботы);
	
	// Запись оптимальнее выполнять по годам.
	// Выбираем используемые годы
	// Для каждого года 
	// - считываем набор, 
	// - модифицируем его с учетом записываемых данных
	// - записываем.
	
	ДанныеПоГодам = Новый Соответствие;
	
	ДатаДня = ДатаНачала;
	Пока ДатаДня <= ДатаОкончания Цикл
		ДанныеПоГодам.Вставить(Год(ДатаДня), Истина);
		ДатаДня = ДатаДня + ДлительностьСутокВСекундах();
	КонецЦикла;
	
	РучныеИзменения = Неопределено;
	Если Не ЗамещатьРучныеИзменения Тогда
		РучныеИзменения = РучныеИзмененияГрафика(ГрафикРаботы);
	КонецЕсли;
	
	// Обрабатываем данные по годам.
	Для Каждого КлючИЗначение Из ДанныеПоГодам Цикл
		Год = КлючИЗначение.Ключ;
		// Считываем наборы на год
		НаборДни.Отбор.Год.Установить(Год);
		НачатьТранзакцию();
		Попытка
			БлокировкаДанных = Новый БлокировкаДанных;
			ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрСведений.КалендарныеГрафики");
			ЭлементБлокировки.УстановитьЗначение("Календарь", ГрафикРаботы);
			ЭлементБлокировки.УстановитьЗначение("Год", Год);
			БлокировкаДанных.Заблокировать();
			НаборДни.Прочитать();
			ЗаполнитьНаборДнейНаГод(НаборДни, ДниВключенныеВГрафик, Год, ГрафикРаботы, РучныеИзменения, ДатаНачала, ДатаОкончания);
			Если ОбновлениеИнформационнойБазы.ЭтоВызовИзОбработчикаОбновления() Тогда
				ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборДни);
			Иначе
				НаборДни.Записать();
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьНаборДнейНаГод(НаборДни, ДниВключенныеВГрафик, Год, ГрафикРаботы, РучныеИзменения, ДатаНачала, ДатаОкончания)
	
	// Заполняем содержимое набора в соответствие по датам для быстрого доступа.
	СтрокиНабораДни = Новый Соответствие;
	Для Каждого СтрокаНабора Из НаборДни Цикл
		СтрокиНабораДни.Вставить(СтрокаНабора.ДатаГрафика, СтрокаНабора);
	КонецЦикла;
	
	НачалоГода = Дата(Год, 1, 1);
	КонецГода = Дата(Год, 12, 31);
	
	НачалоОбхода = ?(ДатаНачала > НачалоГода, ДатаНачала, НачалоГода);
	КонецОбхода = ?(ДатаОкончания < КонецГода, ДатаОкончания, КонецГода);
	
	// Для периода обхода данные в наборе должны быть заменены.
	ДатаДня = НачалоОбхода;
	Пока ДатаДня <= КонецОбхода Цикл
		
		Если РучныеИзменения <> Неопределено И РучныеИзменения[ДатаДня] <> Неопределено Тогда
			// Оставляем без изменений в наборе ручные корректировки.
			ДатаДня = ДатаДня + ДлительностьСутокВСекундах();
			Продолжить;
		КонецЕсли;
		
		// Если строки на дату нет в наборе - создаем ее.
		СтрокаНабораДни = СтрокиНабораДни[ДатаДня];
		Если СтрокаНабораДни = Неопределено Тогда
			СтрокаНабораДни = НаборДни.Добавить();
			СтрокаНабораДни.Календарь = ГрафикРаботы;
			СтрокаНабораДни.Год = Год;
			СтрокаНабораДни.ДатаГрафика = ДатаДня;
			СтрокиНабораДни.Вставить(ДатаДня, СтрокаНабораДни);
		КонецЕсли;
		
		// Если день включен в график, то заполним его интервалы.
		ДанныеДня = ДниВключенныеВГрафик.Получить(ДатаДня);
		Если ДанныеДня = Неопределено Тогда
			// Удаляем строку из набора, если день - нерабочий.
			НаборДни.Удалить(СтрокаНабораДни);
			СтрокиНабораДни.Удалить(ДатаДня);
		Иначе
			СтрокаНабораДни.ДеньВключенВГрафик = Истина;
		КонецЕсли;
		ДатаДня = ДатаДня + ДлительностьСутокВСекундах();
	КонецЦикла;
	
	// Заполняем вторичные данные для оптимизации расчетов по календарям.
	ДатаОбхода = НачалоГода;
	КоличествоДнейВГрафикеСНачалаГода = 0;
	Пока ДатаОбхода <= КонецГода Цикл
		СтрокаНабораДни = СтрокиНабораДни[ДатаОбхода];
		Если СтрокаНабораДни <> Неопределено Тогда
			// День включен в график
			КоличествоДнейВГрафикеСНачалаГода = КоличествоДнейВГрафикеСНачалаГода + 1;
		Иначе
			// День не включен в график
			СтрокаНабораДни = НаборДни.Добавить();
			СтрокаНабораДни.Календарь = ГрафикРаботы;
			СтрокаНабораДни.Год = Год;
			СтрокаНабораДни.ДатаГрафика = ДатаОбхода;
		КонецЕсли;
		СтрокаНабораДни.КоличествоДнейВГрафикеСНачалаГода = КоличествоДнейВГрафикеСНачалаГода;
		ДатаОбхода = ДатаОбхода + ДлительностьСутокВСекундах();
	КонецЦикла;
	
КонецПроцедуры

// Конструктор параметров заполнения графика работы для методов: 
// ДниВключенныеВГрафик, ДниВключенныеВГрафикПоНеделям, ДниВключенныеВГрафикПроизвольнойДлины. 
// 
// Возвращаемое значение:
// 	Структура:
//   * ПроизводственныйКалендарь 
//   * СпособЗаполнения 
//   * ШаблонЗаполнения 
//   * УчитыватьПраздники 
//   * УчитыватьНерабочиеПериоды 
//   * НерабочиеПериоды 
//   * ДатаОтсчета 
//
Функция ПараметрыЗаполненияГрафика() Экспорт
	ПараметрыЗаполнения = Новый Структура(
		"ПроизводственныйКалендарь,
		|СпособЗаполнения,
		|ШаблонЗаполнения,
		|УчитыватьПраздники,
		|УчитыватьНерабочиеПериоды,
		|НерабочиеПериоды,
		|ДатаОтсчета");
	ПараметрыЗаполнения.СпособЗаполнения = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоНеделям;
	ПараметрыЗаполнения.НерабочиеПериоды = Новый Массив;
	Возврат ПараметрыЗаполнения;
КонецФункции

// Составляет коллекцию дат, являющихся рабочими с учетом производственного календаря, 
//  способа заполнения и других настроек.
// 
// Параметры:
// 	ДатаНачала - Дата - начало заполнения данных.
// 	ДатаОкончания - Дата - окончание заполнения данных.
// 	ПараметрыЗаполнения - см. ПараметрыЗаполнения.
//
// Возвращаемое значение:
// 	Соответствие - где Ключ - дата, значение массив структур с описанием интервалов времени для:
//   указанной даты.
//
Функция ДниВключенныеВГрафик(ДатаНачала, ДатаОкончания, ПараметрыЗаполнения) Экспорт
	
	ДниВключенныеВГрафик = Новый Соответствие;
	
	Если ПараметрыЗаполнения.ШаблонЗаполнения.Количество() = 0 Тогда
		Возврат ДниВключенныеВГрафик;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ДатаОкончания) Тогда
		// Если дата окончания не указана, то заполняем до конца года.
		ДатаОкончания = КонецГода(ДатаНачала);
		Если ЗначениеЗаполнено(ПараметрыЗаполнения.ПроизводственныйКалендарь) Тогда
			// Если указан производственный календарь, то заполняем до "конца" его заполненности.
			ДатаОкончанияЗаполнения = Справочники.ПроизводственныеКалендари.ДатаОкончанияЗаполненияПроизводственногоКалендаря(
				ПараметрыЗаполнения.ПроизводственныйКалендарь);
			Если ДатаОкончанияЗаполнения <> Неопределено 
				И ДатаОкончанияЗаполнения > ДатаОкончания Тогда
				ДатаОкончания = ДатаОкончанияЗаполнения;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыЗаполнения.ПроизводственныйКалендарь) Тогда
		ПараметрыЗаполнения.НерабочиеПериоды = КалендарныеГрафики.ПериодыНерабочихДней(
			ПараметрыЗаполнения.ПроизводственныйКалендарь, Новый СтандартныйПериод(ДатаНачала, ДатаОкончания));
	КонецЕсли;
	
	// Заполнение данных производится по годам.
	ТекущийГод = Год(ДатаНачала);
	Пока ТекущийГод <= Год(ДатаОкончания) Цикл
		ДатаНачалаВГоду = ДатаНачала;
		ДатаОкончанияВГоду = ДатаОкончания;
		СкорректироватьДатыНачалаОкончания(ТекущийГод, ДатаНачалаВГоду, ДатаОкончанияВГоду);
		// Получаем данные графика за год.
		Если ПараметрыЗаполнения.СпособЗаполнения = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоНеделям Тогда
			ДниЗаГод = ДниВключенныеВГрафикПоНеделям(ТекущийГод, ПараметрыЗаполнения, ДатаНачалаВГоду, ДатаОкончанияВГоду);
		Иначе
			ДниЗаГод = ДниВключенныеВГрафикПроизвольнойДлины(ТекущийГод, ПараметрыЗаполнения, ДатаНачалаВГоду, ДатаОкончанияВГоду);
		КонецЕсли;
		// Дополняем общую коллекцию
		Для Каждого КлючИЗначение Из ДниЗаГод Цикл
			ДниВключенныеВГрафик.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
		КонецЦикла;
		ТекущийГод = ТекущийГод + 1;
	КонецЦикла;
	
	Возврат ДниВключенныеВГрафик;
	
КонецФункции

Функция ДниВключенныеВГрафикПоНеделям(Год, ПараметрыЗаполнения, 
	Знач ДатаНачала = Неопределено, Знач ДатаОкончания = Неопределено)
	
	ДниВключенныеВГрафик = Новый Соответствие;
	
	ЗаполнятьПоПроизводственномуКалендарю = ЗначениеЗаполнено(ПараметрыЗаполнения.ПроизводственныйКалендарь);
	
	ДнейВГоду = ДеньГода(Дата(Год, 12, 31));
	ДанныеПроизводственногоКалендаря = Справочники.ПроизводственныеКалендари.ДанныеПроизводственногоКалендаря(
		ПараметрыЗаполнения.ПроизводственныйКалендарь, Год);
	Если ЗаполнятьПоПроизводственномуКалендарю 
		И ДанныеПроизводственногоКалендаря.Количество() <> ДнейВГоду Тогда
		// Если производственный календарь указан, но заполнен неправильно, заполнение по неделям не поддерживается.
		Возврат ДниВключенныеВГрафик;
	КонецЕсли;
	
	ДанныеПроизводственногоКалендаря.Индексы.Добавить("Дата");
	
	ДатаДня = ДатаНачала;
	Пока ДатаДня <= ДатаОкончания Цикл
		НомерДня = ДеньНедели(ДатаДня);
		Если ЗаполнятьПоПроизводственномуКалендарю Тогда
			Если ПараметрыЗаполнения.УчитыватьПраздники Или ПараметрыЗаполнения.НерабочиеПериоды.Количество() > 0 Тогда 
				ДанныеДня = ДанныеПроизводственногоКалендаря.НайтиСтроки(Новый Структура("Дата", ДатаДня))[0];
				НомерДня = НомерДняШаблона(ДанныеДня, ПараметрыЗаполнения);
			КонецЕсли;
		КонецЕсли;
		Если НомерДня <> Неопределено Тогда
			СтрокаДня = ПараметрыЗаполнения.ШаблонЗаполнения[НомерДня - 1];
			Если СтрокаДня.ДеньВключенВГрафик Тогда
				ДниВключенныеВГрафик.Вставить(ДатаДня, Истина);
			КонецЕсли;
		КонецЕсли;
		ДатаДня = ДатаДня + ДлительностьСутокВСекундах();
	КонецЦикла;
	
	Возврат ДниВключенныеВГрафик;
	
КонецФункции

Функция ДниВключенныеВГрафикПроизвольнойДлины(Год, ПараметрыЗаполнения, 
	Знач ДатаНачала = Неопределено, Знач ДатаОкончания = Неопределено)
	
	ДниВключенныеВГрафик = Новый Соответствие;
	
	ДатаДня = ПараметрыЗаполнения.ДатаОтсчета;
	Пока ДатаДня <= ДатаОкончания Цикл
		Для Каждого СтрокаДня Из ПараметрыЗаполнения.ШаблонЗаполнения Цикл
			Если СтрокаДня.ДеньВключенВГрафик 
				И ДатаДня >= ДатаНачала Тогда
				ДниВключенныеВГрафик.Вставить(ДатаДня, Истина);
			КонецЕсли;
			ДатаДня = ДатаДня + ДлительностьСутокВСекундах();
		КонецЦикла;
	КонецЦикла;
	
	Если Не ПараметрыЗаполнения.УчитыватьПраздники И ПараметрыЗаполнения.НерабочиеПериоды.Количество() = 0 Тогда  
		Возврат ДниВключенныеВГрафик;
	КонецЕсли;
	
	// Исключаем даты праздничных дней.
	
	ДанныеПроизводственногоКалендаря = Справочники.ПроизводственныеКалендари.ДанныеПроизводственногоКалендаря(
		ПараметрыЗаполнения.ПроизводственныйКалендарь, Год);
	Если ДанныеПроизводственногоКалендаря.Количество() = 0 Тогда
		Возврат ДниВключенныеВГрафик;
	КонецЕсли;
	
	Если ПараметрыЗаполнения.УчитыватьНерабочиеПериоды Тогда 
		ДанныеПроизводственногоКалендаря.Индексы.Добавить("Дата");
		Для Каждого НерабочийПериод Из ПараметрыЗаполнения.НерабочиеПериоды Цикл
			Для Каждого Дата Из НерабочийПериод.Даты Цикл
				ДниВключенныеВГрафик.Удалить(Дата);
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
	Если ПараметрыЗаполнения.УчитыватьПраздники Тогда
		ДанныеПроизводственногоКалендаря.Индексы.Добавить("ВидДня");
		ОтборСтрок = Новый Структура("ВидДня");
		ОтборСтрок.ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Праздник;
		ДанныеПраздничныхДней = ДанныеПроизводственногоКалендаря.НайтиСтроки(ОтборСтрок);
		Для Каждого ДанныеДня Из ДанныеПраздничныхДней Цикл
			ДниВключенныеВГрафик.Удалить(ДанныеДня.Дата);
		КонецЦикла;
		ДатыНерабочихПериодов = Новый Массив;
		ОтборСтрок.ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Нерабочий;
		ДанныеНерабочихДней = ДанныеПроизводственногоКалендаря.НайтиСтроки(ОтборСтрок);
		Если ДанныеНерабочихДней.Количество() > 0 Тогда
			Если Не ПараметрыЗаполнения.УчитыватьНерабочиеПериоды Тогда
				Для Каждого НерабочийПериод Из ПараметрыЗаполнения.НерабочиеПериоды Цикл
					ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ДатыНерабочихПериодов, НерабочийПериод.Даты);
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		Для Каждого ДанныеДня Из ДанныеНерабочихДней Цикл
			Если ДатыНерабочихПериодов.Найти(ДанныеДня.Дата) = Неопределено Тогда
				ДниВключенныеВГрафик.Удалить(ДанныеДня.Дата);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
		
	Возврат ДниВключенныеВГрафик;
	
КонецФункции

Процедура СкорректироватьДатыНачалаОкончания(Год, ДатаНачала, ДатаОкончания)
	
	НачалоГода = Дата(Год, 1, 1);
	КонецГода = Дата(Год, 12, 31);
	
	Если ДатаНачала <> Неопределено Тогда
		ДатаНачала = Макс(ДатаНачала, НачалоГода);
	Иначе
		ДатаНачала = НачалоГода;
	КонецЕсли;
	
	Если ДатаОкончания <> Неопределено Тогда
		ДатаОкончания = Мин(ДатаОкончания, КонецГода);
	Иначе
		ДатаОкончания = КонецГода;
	КонецЕсли;
	
КонецПроцедуры

// Определяет даты ручных изменений указанного графика.
//
Функция РучныеИзмененияГрафика(ГрафикРаботы)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	РучныеИзменения.ГрафикРаботы,
	|	РучныеИзменения.Год,
	|	РучныеИзменения.ДатаГрафика,
	|	ЕСТЬNULL(КалендарныеГрафики.ДеньВключенВГрафик, ЛОЖЬ) КАК ДеньВключенВГрафик
	|ИЗ
	|	РегистрСведений.РучныеИзмененияГрафиковРаботы КАК РучныеИзменения
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|		ПО (КалендарныеГрафики.Календарь = РучныеИзменения.ГрафикРаботы)
	|			И (КалендарныеГрафики.Год = РучныеИзменения.Год)
	|			И (КалендарныеГрафики.ДатаГрафика = РучныеИзменения.ДатаГрафика)
	|ГДЕ
	|	РучныеИзменения.ГрафикРаботы = &ГрафикРаботы
	|	И РучныеИзменения.ДатаГрафика <> ДАТАВРЕМЯ(1, 1, 1)");

	Запрос.УстановитьПараметр("ГрафикРаботы", ГрафикРаботы);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	РучныеИзменения = Новый Соответствие;
	Пока Выборка.Следующий() Цикл
		РучныеИзменения.Вставить(Выборка.ДатаГрафика, Выборка.ДеньВключенВГрафик);
	КонецЦикла;
	
	Возврат РучныеИзменения;
	
КонецФункции

Функция НомерДняШаблона(ДанныеДня, ПараметрыЗаполнения)
	
	ВидДня = ДанныеДня.ВидДня;
	Если ЭтаДатаВНерабочемПериоде(ДанныеДня.Дата, ПараметрыЗаполнения.НерабочиеПериоды) Тогда
		Если ПараметрыЗаполнения.УчитыватьНерабочиеПериоды Тогда
			Возврат Неопределено;
		КонецЕсли;
		Если ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Нерабочий Тогда
			ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Рабочий;
		КонецЕсли;
	КонецЕсли;
	
	Если ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Рабочий 
		Или ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Предпраздничный Тогда
		ДатаДня = ДанныеДня.Дата;
		Если ЗначениеЗаполнено(ДанныеДня.ДатаПереноса) Тогда
			ДатаДня = ДанныеДня.ДатаПереноса;
		КонецЕсли;
		Возврат ДеньНедели(ДатаДня);
	КонецЕсли;
	
	Если ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Суббота Тогда
		Возврат 6;
	КонецЕсли;
	
	Если ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Воскресенье Тогда
		Возврат 7;
	КонецЕсли;

	Если ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Праздник 
		Или ВидДня = Перечисления.ВидыДнейПроизводственногоКалендаря.Нерабочий Тогда
		Если ПараметрыЗаполнения.УчитыватьПраздники Тогда
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;

	Возврат ДеньНедели(ДанныеДня.Дата);
	
КонецФункции

Функция ЭтаДатаВНерабочемПериоде(Дата, НерабочиеПериоды)
	
	Для Каждого НерабочийПериод Из НерабочиеПериоды Цикл
		Если НерабочийПериод.Даты.Найти(Дата) <> Неопределено Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
		
КонецФункции

Функция ДлительностьСутокВСекундах()
	Возврат 24 * 60 * 60;
КонецФункции

#КонецОбласти

#КонецЕсли	